*This project is archived in favour of using the official GLFW backend: https://gnimuc.github.io/CImGui.jl/stable/backends/*

# ImGuiGLFWBackend

[![CI](https://github.com/JuliaImGui/ImGuiGLFWBackend.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaImGui/ImGuiGLFWBackend.jl/actions/workflows/ci.yml)
[![TagBot](https://github.com/JuliaImGui/ImGuiGLFWBackend.jl/actions/workflows/TagBot.yml/badge.svg)](https://github.com/JuliaImGui/ImGuiGLFWBackend.jl/actions/workflows/TagBot.yml)
[![Coverage](https://codecov.io/gh/JuliaImGui/ImGuiGLFWBackend.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaImGui/ImGuiGLFWBackend.jl)
[![](https://img.shields.io/badge/design%20principle-KISS-orange)](https://en.wikipedia.org/wiki/KISS_principle)

Julia GLFW backend for ImGui.

## Installation
```
pkg> add ImGuiGLFWBackend
```

## Example

```julia
using ImGuiGLFWBackend
using ImGuiGLFWBackend.LibCImGui
using ImGuiGLFWBackend.LibGLFW
using ImGuiOpenGLBackend
using ImGuiOpenGLBackend.ModernGL

# create contexts
imgui_ctx = igCreateContext(C_NULL)

window_ctx = ImGuiGLFWBackend.create_context()
window = ImGuiGLFWBackend.get_window(window_ctx)

gl_ctx = ImGuiOpenGLBackend.create_context()

# enable docking and multi-viewport
io = igGetIO()
io.ConfigFlags = unsafe_load(io.ConfigFlags) | ImGuiConfigFlags_DockingEnable
io.ConfigFlags = unsafe_load(io.ConfigFlags) | ImGuiConfigFlags_ViewportsEnable

# set style
igStyleColorsDark(C_NULL)

# init
ImGuiGLFWBackend.init(window_ctx)
ImGuiOpenGLBackend.init(gl_ctx)

try
    while glfwWindowShouldClose(window) == GLFW_FALSE
        glfwPollEvents()
        # new frame
        ImGuiOpenGLBackend.new_frame(gl_ctx)
        ImGuiGLFWBackend.new_frame(window_ctx)
        igNewFrame()

        # UIs
        igShowDemoWindow(Ref(true))
        igShowMetricsWindow(Ref(true))

        # rendering
        igRender()
        glfwMakeContextCurrent(window)
        w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)
        glfwGetFramebufferSize(window, w_ref, h_ref)
        display_w, display_h = w_ref[], h_ref[]
        glViewport(0, 0, display_w, display_h)
        glClearColor(0.45, 0.55, 0.60, 1.00)
        glClear(GL_COLOR_BUFFER_BIT)
        ImGuiOpenGLBackend.render(gl_ctx)

        if unsafe_load(igGetIO().ConfigFlags) & ImGuiConfigFlags_ViewportsEnable == ImGuiConfigFlags_ViewportsEnable
            backup_current_context = glfwGetCurrentContext()
            igUpdatePlatformWindows()
            GC.@preserve gl_ctx igRenderPlatformWindowsDefault(C_NULL, pointer_from_objref(gl_ctx))
            glfwMakeContextCurrent(backup_current_context)
        end

        glfwSwapBuffers(window)
    end
catch e
    @error "Error in renderloop!" exception=e
    Base.show_backtrace(stderr, catch_backtrace())
finally
    ImGuiOpenGLBackend.shutdown(gl_ctx)
    ImGuiGLFWBackend.shutdown(window_ctx)
    igDestroyContext(imgui_ctx)
    glfwDestroyWindow(window)
end

```
