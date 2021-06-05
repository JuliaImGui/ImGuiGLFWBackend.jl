module ImGuiGLFWBackend

using Libdl
using GLFW_jll
using LibCImGui

include("LibGLFW.jl")
using .LibGLFW

const GLFW_GET_CLIPBOARD_TEXT_FUNCPTR = Ref{Ptr{Cvoid}}(C_NULL)
const GLFW_SET_CLIPBOARD_TEXT_FUNCPTR = Ref{Ptr{Cvoid}}(C_NULL)

function __init__()
    glfwInit() == GLFW_TRUE && atexit(glfwTerminate)
    GLFW_GET_CLIPBOARD_TEXT_FUNCPTR[] = dlsym(dlopen(libglfw), :glfwGetClipboardString)
    GLFW_SET_CLIPBOARD_TEXT_FUNCPTR[] = dlsym(dlopen(libglfw), :glfwSetClipboardString)
end

function c_get(x::Ptr{NTuple{N,T}}, i) where {N,T}
    unsafe_load(Ptr{T}(x), Integer(i)+1)
end

function c_set!(x::Ptr{NTuple{N,T}}, i, v) where {N,T}
    unsafe_store!(Ptr{T}(x), v, Integer(i)+1)
end

include("macros.jl")

include("constants.jl")
export GlfwClientApi, GlfwClientApi_Unknown, GlfwClientApi_OpenGL, GlfwClientApi_Vulkan

include("callbacks.jl")

include("context.jl")
export set_default_glfw_window_size, set_default_glfw_window_title

include("platform.jl")
include("interface.jl")

end
