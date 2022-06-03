#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D PrevSampler;
uniform sampler2D VariableSampler;
uniform sampler2D JudgeSampler;

uniform float Time;
in vec2 texCoord;
in vec2 oneTexel;

uniform vec2 InSize;

out vec4 fragColor;

#define PI 3.1415926535897932384626433832795

#define VAR_FPS_TEST 0.0
#define VAR_FPS 1.0
#define VAR_BEAM_FRAME 2.0
#define VAR_SLASH_FRAME 3.0

int imod(int num, int m) {
	return num - (num / m * m);
}

int getVar(sampler2D sampler, float id) {
	vec4 var_color = texture(sampler, vec2((id + 0.5) * 0.01, 0.0));
	return int(var_color.r * 255.0)/4*4096 + int(var_color.g * 255.0)/4*64 + int(var_color.b * 255.0)/4;
}

vec3 hue(float h) {
    float r = abs(h * 6.0 - 3.0) - 1.0;
    float g = 2.0 - abs(h * 6.0 - 2.0);
    float b = 2.0 - abs(h * 6.0 - 4.0);
    return clamp(vec3(r,g,b), 0.0, 1.0);
}

vec3 HSVtoRGB(vec3 hsv) {
    return ((hue(hsv.x) - 1.0) * hsv.y + 1.0) * hsv.z;
}

vec3 RGBtoHSV(vec3 rgb) {
    vec3 hsv = vec3(0.0);
    hsv.z = max(rgb.r, max(rgb.g, rgb.b));
    float min = min(rgb.r, min(rgb.g, rgb.b));
    float c = hsv.z - min;

    if (c != 0.0)
    {
        hsv.y = c / hsv.z;
        vec3 delta = (hsv.z - rgb) / c;
        delta.rgb -= delta.brg;
        delta.rg += vec2(2.0, 4.0);
        if (rgb.r >= hsv.z) {
            hsv.x = delta.b;
        } else if (rgb.g >= hsv.z) {
            hsv.x = delta.r;
        } else {
            hsv.x = delta.g;
        }
        hsv.x = fract(hsv.x / 6.0);
    }
    return hsv;
}

vec4 blendOver(vec4 over, vec4 base) {
	vec3 colorA = over.rgb * over.a + base.rgb * base.a * (1 - over.a);
	float alpha = over.a + base.a * (1 - over.a);
	return vec4(colorA / alpha, alpha);
}



void beamEffect(float anim_time, vec4 CurrTexel, vec4 JudgeTexel) {
	if (JudgeTexel.a > 0.1)
		return;
	
	float r_square = pow((texCoord.x - 0.5) * InSize.x / InSize.y, 2) + pow(texCoord.y - 0.5, 2);
	float r_max_square = 0.0;
	float mask_alpha = 0.0;
	if (anim_time < 0.05) {
		float r_circle = anim_time * 40.0;
		float r = pow(r_square, 0.5);
		float dist = abs(r - r_circle);
		if (dist < 0.1) {
			fragColor = blendOver(vec4(1.0, 1.0, 1.0, (0.1 - dist) * 5.0), CurrTexel);
			return;
		}
	}
	
	if (anim_time < 0.5) {
		r_max_square = pow(0.2 + 0.02 * sin(Time * PI * 16), 2);
		mask_alpha = 0.8;
	}
	else {
		r_max_square = pow(0.4 * (1.0 - anim_time), 2);
		mask_alpha = (1.0 - anim_time) * 1.6;
	}
	
	if (r_square < r_max_square)
		fragColor = vec4(1.0, 1.0, 1.0, 1.0);
	else {
		float alpha = pow(r_max_square / r_square, 0.5);
		if (r_square < r_max_square * 1.44) {
			vec4 color = blendOver(vec4(0.0, 0.0, 0.0, mask_alpha), CurrTexel);
			fragColor = blendOver(vec4((alpha - 0.6944) / 0.3056, 1.0, 1.0, alpha), color);
		}
		else {
			vec4 color = blendOver(vec4(0.0, 0.0, 0.0, mask_alpha), CurrTexel);
			fragColor = blendOver(vec4(0.0, 1.0, 1.0, alpha), color);
		}
	}
}

void darkenEffect(float anim_time, vec4 JudgeTexel, vec4 CurrTexel) {
	if (JudgeTexel.a < 0.1) {
		float r_square = pow((texCoord.x - 0.5) * InSize.x / InSize.y, 2) + pow(texCoord.y - 0.5, 2);
		float r_max_square = pow(0.06 + 0.002 * sin(Time * PI * 8), 2) * anim_time * 2;
		if (r_square < r_max_square)
			fragColor = vec4(1.0, 1.0, 1.0, 1.0);
		else {
			float alpha = r_max_square / r_square;
			float mask_alpha = min(3.2 * anim_time, 0.8);
			
			if (r_square < r_max_square * 1.44) {
				vec4 color = blendOver(vec4(0.0, 0.0, 0.0, mask_alpha), CurrTexel);
				fragColor = blendOver(vec4((alpha - 0.6944) / 0.3056, 1.0, 1.0, alpha), color);
			}
			else {
				vec4 color = blendOver(vec4(0.0, 0.0, 0.0, mask_alpha), CurrTexel);
				fragColor = blendOver(vec4(0.0, 1.0, 1.0, alpha), color);
			}
		}
	}
	else {
		vec3 color = RGBtoHSV(CurrTexel.rgb);
		fragColor = vec4(HSVtoRGB(vec3(color.rg, color.b + 0.1)), 1.0);
	}
}

void splitEffect(float slash_time, vec4 CurrTexel) {
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	float white_range = 0.001;
	float mid_dist = abs(texCoord.x - 0.5);
	
	if (slash_time < 1.2) {
		float offset = min(slash_time, 0.1) * 0.5;
		if (texCoord.x < 0.499) {
			if (texCoord.y < 1.0 - offset)
				color = texture(DiffuseSampler, vec2(texCoord.x, texCoord.y + offset));
		}
		else if (texCoord.x > 0.501) {
			if (texCoord.y > offset)
				color = texture(DiffuseSampler, vec2(texCoord.x, texCoord.y - offset));
		}
		
		if (slash_time < 1.0) {
			if (mid_dist < white_range)
				color = vec4(1.0, 1.0, 1.0, 1.0);
			
			if (mid_dist > white_range && mid_dist < white_range + 0.005) {
				float alpha = 0.6 - (mid_dist - white_range) * 100.0;
				color = blendOver(vec4(1.0, 0.0, 0.0, alpha), color);
			}
		}
		else {
			white_range = (slash_time - 1.0) * 5.0;
			if (mid_dist < white_range)
				color = vec4(1.0, 1.0, 1.0, 1.0);
			
			float fade_range = min(slash_time - 1.0, 0.1);
			if (mid_dist > white_range && mid_dist < white_range + fade_range) {
				float alpha = (fade_range - mid_dist + white_range) * 10.0;
				float red_scale = (fade_range - mid_dist + white_range) / fade_range;
				color = blendOver(vec4(1.0, red_scale, red_scale, alpha), color);
			}
		}
	}
	else {
		float alpha = (1.5 - slash_time) * 3.333;
		color = blendOver(vec4(1.0, 1.0, 1.0, alpha), CurrTexel);
	}
	
	fragColor = color;
}

void main() {
	vec4 PrevTexel = texture(PrevSampler, texCoord);
	vec4 CurrTexel = texture(DiffuseSampler, texCoord);
	vec4 JudgeTexel = texture(JudgeSampler, texCoord);
	fragColor = vec4(0.0, 0.0, 0.0, 0.0);
	
	int fps = getVar(VariableSampler, VAR_FPS) * 5 / 4;
	if (fps == 0)
		fps = 60;
	
	int beam_frame = getVar(VariableSampler, VAR_BEAM_FRAME);
	int slash_frame = getVar(VariableSampler, VAR_SLASH_FRAME);
	if (beam_frame > 1) {
		float anim_time = float(beam_frame) / float(fps);
		if (anim_time < 0.5)
			darkenEffect(anim_time, JudgeTexel, CurrTexel);
		else
			beamEffect(anim_time - 0.5, CurrTexel, JudgeTexel);
	}
	else if (slash_frame > 1) {
		float slash_time = float(slash_frame) / float(fps);
		splitEffect(slash_time, CurrTexel);
	}
	else {
		vec4 CheckModeTexel = texture2D(JudgeSampler, vec2(0.5, 0.45));
		if (CheckModeTexel.r < 0.35 && CheckModeTexel.g > 0.975 && CheckModeTexel.b < 0.35)
			fragColor = CurrTexel;
	}
}
