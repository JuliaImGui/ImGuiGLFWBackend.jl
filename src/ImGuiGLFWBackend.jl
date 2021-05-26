module ImGuiGLFWBackend

using Libdl
using GLFW
using LibCImGui

include("LibGLFW.jl")
using .LibGLFW

const GLFW_GET_CLIPBOARD_TEXT_FUNCPTR = Ref{Ptr{Cvoid}}(C_NULL)
const GLFW_SET_CLIPBOARD_TEXT_FUNCPTR = Ref{Ptr{Cvoid}}(C_NULL)

function __init__()
    GLFW_GET_CLIPBOARD_TEXT_FUNCPTR[] = dlsym(dlopen(GLFW.libglfw), :glfwGetClipboardString)
    GLFW_SET_CLIPBOARD_TEXT_FUNCPTR[] = dlsym(dlopen(GLFW.libglfw), :glfwSetClipboardString)
end

Base.convert(::Type{Cint}, x::GLFW.Key) = Cint(x)

function c_get(x::Ptr{NTuple{N,T}}, i) where {N,T}
    unsafe_load(Ptr{T}(x), Integer(i)+1)
end

function c_set!(x::Ptr{NTuple{N,T}}, i, v) where {N,T}
    unsafe_store!(Ptr{T}(x), v, Integer(i)+1)
end

include("constants.jl")
export GlfwClientApi, GlfwClientApi_Unknown, GlfwClientApi_OpenGL, GlfwClientApi_Vulkan

include("context.jl")
export set_default_glfw_window_size, set_default_glfw_window_title

include("callbacks.jl")
include("platform.jl")
include("interface.jl")

end
