#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 u_flatcolor;

void main (void) {
	gl_FragColor = vec4(u_flatcolor, 1.0);
}
