using ImGuiGLFWBackend
using ImGuiGLFWBackend.LibCImGui
using ImGuiGLFWBackend.LibGLFW

glfw_ctx = ImGuiGLFWBackend.create_context()
window = glfw_ctx.Window

imgui_ctx = igCreateContext(C_NULL)

io = igGetIO()
io.ConfigFlags = unsafe_load(io.ConfigFlags) | ImGuiConfigFlags_DockingEnable
io.ConfigFlags = unsafe_load(io.ConfigFlags) | ImGuiConfigFlags_ViewportsEnable

igStyleColorsDark(C_NULL)

using CImGui.OpenGLBackend
using CImGui.OpenGLBackend.ModernGL

# setup Platform/Renderer bindings
ImGuiGLFWBackend.init(glfw_ctx)
ImGui_ImplOpenGL3_Init()

try
    while glfwWindowShouldClose(window) == GLFW_FALSE
        glfwPollEvents()
        # start the Dear ImGui frame
        ImGui_ImplOpenGL3_NewFrame()
        ImGuiGLFWBackend.new_frame(glfw_ctx)
        igNewFrame()

        igShowDemoWindow(Ref(true))

        # rendering
        igRender()
        glfwMakeContextCurrent(window)
        w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)
        glfwGetFramebufferSize(window, w_ref, h_ref)
        display_w, display_h = w_ref[], h_ref[]
        glViewport(0, 0, display_w, display_h)
        glClearColor(0.0f0, 0.0f0, 0.0f0, 1.0f0)
        glClear(GL_COLOR_BUFFER_BIT)
        ImGui_ImplOpenGL3_RenderDrawData(igGetDrawData())

        if unsafe_load(igGetIO().ConfigFlags) & ImGuiConfigFlags_ViewportsEnable != 0
            backup_current_context = glfwGetCurrentContext()
            igUpdatePlatformWindows()
            igRenderPlatformWindowsDefault(C_NULL, C_NULL)
            glfwMakeContextCurrent(backup_current_context)
        end

        glfwSwapBuffers(window)
    end
catch e
    @error "Error in renderloop!" exception=e
    Base.show_backtrace(stderr, catch_backtrace())
finally
    ImGui_ImplOpenGL3_Shutdown()
    ImGuiGLFWBackend.shutdown(glfw_ctx)
    igDestroyContext(imgui_ctx)
    glfwDestroyWindow(window)
end
