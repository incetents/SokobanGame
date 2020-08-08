//
uniform mat4 transform;

attribute vec4 position;
attribute vec2 texCoord;
//attribute vec4 color;
//attribute vec3 normal;

varying vec4 vertPosition;

void main()
{
  gl_Position = transform * position;
  vertPosition = position;
}