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

void main() {
	float anim = max(sin(GameTime * 6000), 0) * 0.7;
	vec4 ori_color = texture(Sampler0, texCoord0);
	bool is_light_blue = (ori_color.r < ori_color.g * 0.6 && ori_color.g > 0.6 && ori_color.b > 0.6) || (ori_color.g > 0.9 && ori_color.b > 0.9);
	bool is_white = (ori_color.r > 0.9 && ori_color.g > 0.9 && ori_color.b > 0.9);
	
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
	else if (!is_light_blue) {
		color *= vertexColor;
	}
	else if (is_light_blue && !is_white) {
		color = color * (1 - anim) + vec4(1, 1, 1, 0.7) * anim;
	}
	
	fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
