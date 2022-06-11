#version 150

#moj_import <light.glsl>
#moj_import <vsh_util.glsl>
#moj_import <define.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

out float alpha;

void main() {
	alpha = 1.0;
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
	
	vec4 vertexTexel = texture(Sampler0, UV0);
	if (vertexTexel.r > 0.99 && vertexTexel.g > 0.99 && vertexTexel.b > 0.99) {
		if (vertexTexel.a < 0.015 && vertexTexel.a > 0.0) {
			// float vertexId = mod(gl_VertexID, 4.0);
			float vertexId = 0.0;
			if (vertexTexel.r > 0.997)  // 255, 253, 253
				vertexId = 1.0;
			else if (vertexTexel.r > 0.993)  // 254, 253, 253
				vertexId = 2.0;
			else if (vertexTexel.g > 0.997)  // 253, 255, 253
				vertexId = 3.0;
			else if (vertexTexel.g > 0.993)  // 253, 254, 253
				vertexId = 0.0;
			mat3 WorldMat = getWorldMat(Light0_Direction, Light1_Direction);
			
			alpha = Color.b / 0.9803921568627451;
			float expand = alpha * 1.5;
			float facing = (Color.g - 0.5) * PI * 2.0;
			
			float theta = fract(GameTime * 300) * PI * 2;
			if (vertexId == 0.0) {
				float horizonOffset = expand * sin(PI * 0.25 + theta);
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(horizonOffset * cos(facing), expand * cos(PI * 0.25 + theta), horizonOffset * sin(facing)), 1.0);
			}
			else if (vertexId == 1.0) {
				float horizonOffset = expand * sin(PI * 0.75 + theta);
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(horizonOffset * cos(facing), expand * cos(PI * 0.75 + theta), horizonOffset * sin(facing)), 1.0);
			}
			else if (vertexId == 2.0) {
				float horizonOffset = expand * sin(PI * -0.75 + theta);
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(horizonOffset * cos(facing), expand * cos(PI * -0.75 + theta), horizonOffset * sin(facing)), 1.0);
			}
			else {
				float horizonOffset = expand * sin(PI * -0.25 + theta);
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(horizonOffset * cos(facing), expand * cos(PI * -0.25 + theta), horizonOffset * sin(facing)), 1.0);
			}
			
			vertexColor = vec4(1.0, 1.0, 1.0, 1.0);
		}
		else if (vertexTexel.a < 0.025 && vertexTexel.a > 0.015) {
			float vertexId = float(mod(gl_VertexID, 4));
			mat3 WorldMat = getWorldMat(Light0_Direction, Light1_Direction);
			
			float size = Color.b * 51.0;
			float theta = -Color.g * PI * 2.0;  // clockwise
			if (vertexId == 0.0) {
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(size * sin(PI * 0.25 + theta), 0.0, size * cos(PI * 0.25 + theta)), 1.0);
			}
			else if (vertexId == 1.0) {
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(size * sin(PI * 0.75 + theta), 0.0, size * cos(PI * 0.75 + theta)), 1.0);
			}
			else if (vertexId == 2.0) {
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(size * sin(PI * -0.75 + theta), 0.0, size * cos(PI * -0.75 + theta)), 1.0);
			}
			else {
				gl_Position = ProjMat * ModelViewMat * vec4(Position + WorldMat * vec3(size * sin(PI * -0.25 + theta), 0.0, size * cos(PI * -0.25 + theta)), 1.0);
			}
			
			vertexColor = vec4(1.0, 1.0, 1.0, 1.0);
		}
	}

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
