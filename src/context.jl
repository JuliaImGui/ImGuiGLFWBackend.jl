"""
    mutable struct Context
A contextual data object.
"""
Base.@kwdef mutable struct Context
    id::Int=new_id()
    Window::GLFW.Window = GLFW.Window(C_NULL)
    ClientApi::GlfwClientApi = GlfwClientApi_Unknown
    Time::Cfloat = Cfloat(0.0f0)
    MouseJustPressed::Vector{Bool} = [false, false, false, false, false]
    MouseCursors::Vector{GLFW.Cursor} = fill(GLFW.Cursor(C_NULL), Int(ImGuiMouseCursor_COUNT))
    KeyOwnerWindows::Vector{GLFW.Window} = fill(GLFW.Window(C_NULL), 512)
    InstalledCallbacks::Bool = false
    WantUpdateMonitors::Bool = true
    PrevUserCallbackMousebutton::Ptr{Cvoid} = C_NULL
    PrevUserCallbackScroll::Ptr{Cvoid} = C_NULL
    PrevUserCallbackKey::Ptr{Cvoid} = C_NULL
    PrevUserCallbackChar::Ptr{Cvoid} = C_NULL
    PrevUserCallbackMonitor::Ptr{Cvoid} = C_NULL
    Monitors::Vector{ImGuiPlatformMonitor} = Vector{ImGuiPlatformMonitor}(undef, 0)
end

const __GLFW_CONTEXTS = Dict{Int,Context}()
const __GLFW_CONTEXT_COUNTER = Threads.Atomic{Int}(0)

reset_counter() = Threads.atomic_sub!(__GLFW_CONTEXT_COUNTER,  __GLFW_CONTEXT_COUNTER[])
add_counter() = Threads.atomic_add!(__GLFW_CONTEXT_COUNTER, 1)
get_counter() = __GLFW_CONTEXT_COUNTER[]
new_id() = (add_counter(); get_counter();)

"""
    create_context(window=GLFW.Window(C_NULL); install_callbacks=true, client_api=GlfwClientApi_OpenGL)
Return a GLFW backend contextual data object.
"""
function create_context(window::GLFW.Window=GLFW.Window(C_NULL); install_callbacks::Bool=true, client_api::GlfwClientApi=GlfwClientApi_OpenGL)
    client_api == GlfwClientApi_Unknown && throw(ArgumentError("Expected input argument `client_api`: `GlfwClientApi_OpenGL` or `GlfwClientApi_Vulkan`, got `GlfwClientApi_Unknown`."))
    client_api == GlfwClientApi_Vulkan && throw(ArgumentError("Backend support for Vulkan has not been implemented yet, please use `GlfwClientApi_OpenGL` instead."))

    if window.handle == C_NULL
        ctx = create_default_context()
    else
        ctx = Context(; Window=window)
    end

    # store the ctx in a global variable to prevent it from being GC-ed
    __GLFW_CONTEXTS[ctx.id] = ctx

    # set window userdata
    ccall((:glfwSetWindowUserPointer, GLFW.libglfw), Cvoid, (GLFW.Window, Ptr{Cvoid}), ctx.Window, pointer_from_objref(ctx))

    return ctx
end

"""
    release_context(ctx::Context)
Relese the ctx so it can be GC-ed.
"""
release_context(ctx::Context) = delete!(__GLFW_CONTEXTS, ctx.id)

default_error_callback(err::GLFW.GLFWError) = @error "GLFW ERROR: code $(err.code) msg: $(err.description)"

function create_default_context()
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 2)
    @static if Sys.isapple()
        GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE) # 3.2+ only
        GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, true) # required on Mac
    end
    GLFW.SetErrorCallback(default_error_callback)
    w, h = GLFW_WINDOW_DEFAULT_SIZE[]
    window = GLFW.CreateWindow(w, h, GLFW_WINDOW_DEFAULT_TITLE[])
    @assert window.handle != C_NULL "failed to create GLFW window."
    GLFW.MakeContextCurrent(window)
    GLFW.SwapInterval(1)  # enable vsync
    return Context(; Window=window)
end

set_default_glfw_window_size(width::Integer, height::Integer) = (GLFW_WINDOW_DEFAULT_SIZE[] = (width, height);)
set_default_glfw_window_title(title::AbstractString) = (GLFW_WINDOW_DEFAULT_TITLE[] = title;)

get_window(ctx::Context) = ctx.Window
