#include <iostream>
#ifdef __EMSCRIPTEN__
#include <GLFW/glfw3.h>
#include <emscripten.h>
#include <GLES3/gl3.h>
#else
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#endif

// Shader sources - WebGL 2.0 compatible
const char* vertexShaderSource =
"#version 300 es\n"
"in vec3 aPos;\n"
"in vec3 aColor;\n"
"out vec3 vColor;\n"
"void main() {\n"
"    gl_Position = vec4(aPos, 1.0);\n"
"    vColor = aColor;\n"
"}\n";

const char* fragmentShaderSource =
"#version 300 es\n"
"precision mediump float;\n"
"in vec3 vColor;\n"
"out vec4 FragColor;\n"
"void main() {\n"
"    FragColor = vec4(vColor, 1.0);\n"
"}\n";

// Global variables
GLFWwindow* window = nullptr;
GLuint shaderProgram;
GLuint VAO, VBO, EBO;

// Function prototypes
void init();
void render_frame();
void cleanup();

#ifdef __EMSCRIPTEN__
void emscripten_loop() {
    render_frame();
}
#endif

int main() {
    // Initialize GLFW and create window
    if (!glfwInit()) {
        std::cerr << "Failed to initialize GLFW" << std::endl;
        return -1;
    }

    // Configure GLFW for WebGL compatibility
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_ANY_PROFILE);

    window = glfwCreateWindow(800, 600, "OpenGL Triangle", nullptr, nullptr);
    if (!window) {
        std::cerr << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    
    // Initialize GLAD (only for native build)
#ifndef __EMSCRIPTEN__
    if (!gladLoadGL()) {
        std::cerr << "Failed to initialize GLAD" << std::endl;
        glfwTerminate();
        return -1;
    }
#endif
    
    // Set up OpenGL resources
    init();

    // Main loop
#ifdef __EMSCRIPTEN__
    // Emscripten: register main loop
    emscripten_set_main_loop(emscripten_loop, 0, 1);
#else
    // Native: use regular loop
    while (!glfwWindowShouldClose(window)) {
        render_frame();
        glfwPollEvents();
    }
    
    // Clean up
    cleanup();
    glfwTerminate();
#endif

    return 0;
}

void init() {
    // Compile vertex shader
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, nullptr);
    glCompileShader(vertexShader);

    // Check vertex shader compilation
    GLint success;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(vertexShader, 512, nullptr, infoLog);
        std::cerr << "Vertex shader compilation failed: " << infoLog << std::endl;
    }

    // Compile fragment shader
    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, nullptr);
    glCompileShader(fragmentShader);
    
    // Check fragment shader compilation
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(fragmentShader, 512, nullptr, infoLog);
        std::cerr << "Fragment shader compilation failed: " << infoLog << std::endl;
    }

    // Link shaders
    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    
    // Check shader program linking
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetProgramInfoLog(shaderProgram, 512, nullptr, infoLog);
        std::cerr << "Shader program linking failed: " << infoLog << std::endl;
    }
    
    // Clean up shaders after linking
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    // Triangle vertices (position + color)
    float vertices[] = {
        // positions         // colors
        -0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,  // bottom left - red
         0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,  // bottom right - green
         0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f   // top - blue
    };
    
    // Create VAO, VBO
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    
    // Bind the VAO first, then bind and set VBO, and configure vertex attributes
    glBindVertexArray(VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // Get attribute locations
    GLint posAttrib = glGetAttribLocation(shaderProgram, "aPos");
    GLint colorAttrib = glGetAttribLocation(shaderProgram, "aColor");
    
    // Position attribute
    glVertexAttribPointer(posAttrib, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(posAttrib);
    // Color attribute
    glVertexAttribPointer(colorAttrib, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(colorAttrib);

    // Unbind VBO and VAO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

void render_frame() {
    // Clear the color buffer
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    // Use shader program
    glUseProgram(shaderProgram);
    
    // Draw triangle
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // Swap buffers
    glfwSwapBuffers(window);
}

void cleanup() {
    // Delete resources
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);
} 