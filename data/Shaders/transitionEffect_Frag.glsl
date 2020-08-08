//
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
 
varying vec4 vertPosition;
 
uniform float width;
uniform float height;
uniform float t;
uniform float blockCountW;
uniform float blockCountH;

const float hyp = sqrt(2.0);

void main()
{

	float x = (vertPosition.x / width); // 0 to 1
	float y = (vertPosition.y / height); // 0 to 1
	
	x = floor(x * blockCountW) / blockCountW; // bigger texel sampling
	y = floor(y * blockCountH) / blockCountH;

	x = x * 2.0 - 1.0; // -1 to 1
	y = y * 2.0 - 1.0; // -1 to 1
	
	float _distance = sqrt(x * x + y * y);
	if(_distance < t * hyp)
		discard;
	
	gl_FragColor = vec4(1,1,1,1);
}