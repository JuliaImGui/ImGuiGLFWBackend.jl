"""
    mutable struct Context
A contextual data object.
"""
Base.@kwdef mutable struct Context
    id::Int=new_id()
    Window::Ptr{GLFWwindow} = Ptr{GLFWwindow}(C_NULL)
    ClientApi::GlfwClientApi = GlfwClientApi_Unknown
    Time::Cfloat = Cfloat(0.0f0)
    MouseJustPressed::Vector{Bool} = [false, false, false, false, false]
    MouseCursors::Vector{Ptr{GLFWcursor}} = fill(Ptr{GLFWcursor}(C_NULL), Int(ImGuiMouseCursor_COUNT))
    KeyOwnerWindows::Vector{Ptr{GLFWwindow}} = fill(Ptr{GLFWwindow}(C_NULL), 512)
    InstalledCallbacks::Bool = true
    WantUpdateMonitors::Bool = true
    PrevUserCallbackMousebutton::Ptr{Cvoid} = C_NULL
    PrevUserCallbackScroll::Ptr{Cvoid} = C_NULL
    PrevUserCallbackKey::Ptr{Cvoid} = C_NULL
    PrevUserCallbackChar::Ptr{Cvoid} = C_NULL
    PrevUserCallbackMonitor::Ptr{Cvoid} = C_NULL
end

Base.show(io::IO, x::Context) = print(io, "Context(id=$(x.id))")

const __GLFW_CONTEXTS = Dict{Int,Context}()
const __GLFW_CONTEXT_COUNTER = Threads.Atomic{Int}(0)

reset_counter() = Threads.atomic_sub!(__GLFW_CONTEXT_COUNTER,  __GLFW_CONTEXT_COUNTER[])
add_counter() = Threads.atomic_add!(__GLFW_CONTEXT_COUNTER, 1)
get_counter() = __GLFW_CONTEXT_COUNTER[]
new_id() = (add_counter(); get_counter();)

"""
    create_context(window=C_NULL; install_callbacks=true, client_api=GlfwClientApi_OpenGL)
Return a GLFW backend contextual data object.
"""
function create_context(window=C_NULL; install_callbacks::Bool=true, client_api::GlfwClientApi=GlfwClientApi_OpenGL)
    client_api == GlfwClientApi_Unknown && throw(ArgumentError("Expected input argument `client_api`: `GlfwClientApi_OpenGL` or `GlfwClientApi_Vulkan`, got `GlfwClientApi_Unknown`."))
    client_api == GlfwClientApi_Vulkan && throw(ArgumentError("Backend support for Vulkan has not been implemented yet, please use `GlfwClientApi_OpenGL` instead."))

    if window == C_NULL
        ctx = create_default_context()
    else
        ctx = Context(; Window=window)
    end

    ctx.InstalledCallbacks = install_callbacks
    ctx.ClientApi = client_api

    # store the ctx in a global variable to prevent it from being GC-ed
    __GLFW_CONTEXTS[ctx.id] = ctx

    # set window userdata
    glfwSetWindowUserPointer(ctx.Window, pointer_from_objref(ctx))

    return ctx
end

"""
    release_context(ctx::Context)
Relese the ctx so it can be GC-ed.
"""
release_context(ctx::Context) = delete!(__GLFW_CONTEXTS, ctx.id)

function create_default_context()
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2)
    @static if Sys.isapple()
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE) # 3.2+ only
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, true) # required on Mac
    end
    glfwSetErrorCallback(@cfunction(ImGui_ImplGlfw_ErrorCallback, Cvoid, (Cint, Ptr{Cchar})))
    w, h = GLFW_WINDOW_DEFAULT_SIZE[]
    window = glfwCreateWindow(w, h, GLFW_WINDOW_DEFAULT_TITLE[], C_NULL, C_NULL)
    @assert window != C_NULL "failed to create GLFW window."
    glfwMakeContextCurrent(window)
    glfwSwapInterval(1)  # enable vsync
    return Context(; Window=window)
end

set_default_glfw_window_size(width::Integer, height::Integer) = (GLFW_WINDOW_DEFAULT_SIZE[] = (width, height);)
set_default_glfw_window_title(title::AbstractString) = (GLFW_WINDOW_DEFAULT_TITLE[] = title;)

get_window(ctx::Context) = ctx.Window
