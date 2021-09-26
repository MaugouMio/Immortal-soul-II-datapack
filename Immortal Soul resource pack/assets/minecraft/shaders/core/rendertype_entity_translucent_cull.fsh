#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

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

void main() {
	float anim = max(sin(GameTime * 6000), 0) * 0.7;
	vec4 ori_color = texture(Sampler0, texCoord0);
	float hueAngle = RGBtoHSV(ori_color.rgb).x;
	bool is_light_blue = (hueAngle > 0.486) && (hueAngle < 0.625);
	bool is_white = (ori_color.r > 0.99 && ori_color.g > 0.99 && ori_color.b > 0.99);
	bool is_yellow = (hueAngle > 0.111) && (hueAngle < 0.166);
	bool is_red = ori_color.r > 0.9 && ori_color.g < 0.05 && ori_color.b < 0.05;
	
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
	else if (!is_light_blue && !is_white && !is_yellow && !is_red) {
		color *= vertexColor;
	}
	else if (is_light_blue && !is_white) {
		color = color * (1 - anim) + vec4(1, 1, 1, 0.7) * anim;
	}
	
	fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
