#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D JudgeSampler;

uniform float Time;
in vec2 texCoord;
in vec2 oneTexel;

uniform vec2 InSize;

out vec4 fragColor;

#define BEAM_TIME 1.5
#define SLASH_TIME 1.3

#define PI 3.1415926535897932384626433832795

#define VAR_FPS_TEST 0.0
#define VAR_FPS 1.0
#define VAR_BEAM_FRAME 2.0
#define VAR_SLASH_FRAME 3.0
#define VAR_SHAKE_FRAME 4.0

int imod(int num, int m) {
	return num - (num / m * m);
}

int getVar(sampler2D sampler, float id) {
	vec4 var_color = texture2D(sampler, vec2((id + 0.5) * 0.01, 0.0));
	return int(var_color.r * 255.0)/4*4096 + int(var_color.g * 255.0)/4*64 + int(var_color.b * 255.0)/4;
}

void setVar(int num, float id) {
	float r = (float(num / 4096) + 0.5) * 4.0 / 255.0;
	num = imod(num, 4096);
	float g = (float(num / 64) + 0.5) * 4.0 / 255.0;
	float b = (float(imod(num, 64)) + 0.5) * 4.0 / 255.0;
	
	if (texCoord.x > id * 0.01 && texCoord.x <= (id + 1) * 0.01)
		fragColor = vec4(r, g, b, 1.0);
}

void copyVar(sampler2D sampler, float fromID, float toID) {
	if (texCoord.x > toID * 0.01 && texCoord.x <= (toID + 1) * 0.01)
		fragColor = texture2D(sampler, vec2((fromID + 0.5) * 0.01, 0.0));
}



void update_fps() {
	if (Time < 0.1)
		setVar(0, VAR_FPS_TEST);
	else if (Time < 0.9)
		setVar(getVar(DiffuseSampler, VAR_FPS_TEST) + 1, VAR_FPS_TEST);
	else
		copyVar(DiffuseSampler, VAR_FPS_TEST, VAR_FPS);  // record
}

void update_beam(float fps) {
	int nextFrame = getVar(DiffuseSampler, VAR_BEAM_FRAME) + 1;
	if (nextFrame == 1)
		return;
	
	if (nextFrame < BEAM_TIME * fps)
		setVar(nextFrame, VAR_BEAM_FRAME);
	else
		setVar(0, VAR_BEAM_FRAME);
}

void update_slash(float fps) {
	int nextFrame = getVar(DiffuseSampler, VAR_SLASH_FRAME) + 1;
	if (nextFrame == 1)
		return;
	
	if (nextFrame < SLASH_TIME * fps)
		setVar(nextFrame, VAR_SLASH_FRAME);
	else
		setVar(0, VAR_SLASH_FRAME);
}

void update_shake(float fps) {
	int nextFrame = getVar(DiffuseSampler, VAR_SHAKE_FRAME) + 1;
	if (nextFrame >= 60)  // loop at 60
		nextFrame = 0;
	
	setVar(nextFrame, VAR_SHAKE_FRAME);
}

void main() {
	vec4 PrevTexel = texture2D(DiffuseSampler, texCoord);
	fragColor = PrevTexel;
	
	float fps = getVar(DiffuseSampler, VAR_FPS) / 0.8;
	if (fps < 1.0)
		fps = 60.0;
	
	update_fps();
	update_beam(fps);
	update_slash(fps);
	
	vec4 judgeTexel = texture2D(JudgeSampler, vec2(0.5, 0.45));
	if (judgeTexel.r > 0.976 && judgeTexel.g < 0.35 && judgeTexel.b < 0.35)
		setVar(1, VAR_BEAM_FRAME);
	else if (judgeTexel.r < 0.35 && judgeTexel.g < 0.35 && judgeTexel.b > 0.95)
		setVar(1, VAR_SLASH_FRAME);
	else if (judgeTexel.r < 0.35 && judgeTexel.g > 0.975 && judgeTexel.b < 0.35)
		update_shake(fps);
}
