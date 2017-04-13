//position으로 2개의 데이터를 받아옴
attribute vec2 position;
//uniform vec2 translate;

uniform mat4 view;
uniform mat4 projection;

void main() {
    //임시 주석
    //projection * view *
    //gl_Position = projection * view * vec4(position.x + translate.x, position.y + translate.y, 0.0, 1.0);
    gl_Position = projection * view * vec4(position.x, position.y, 0.0, 1.0);
}
