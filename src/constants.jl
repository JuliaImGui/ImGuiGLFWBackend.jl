@enum GlfwClientApi begin
    GlfwClientApi_Unknown
    GlfwClientApi_OpenGL
    GlfwClientApi_Vulkan
end

const GLFW_HAS_WINDOW_TOPMOST = true
const GLFW_HAS_WINDOW_HOVERED = true
const GLFW_HAS_WINDOW_ALPHA = true
const GLFW_HAS_PER_MONITOR_DPI = true
const GLFW_HAS_VULKAN = true
const GLFW_HAS_FOCUS_WINDOW = true
const GLFW_HAS_FOCUS_ON_SHOW = true
const GLFW_HAS_MONITOR_WORK_AREA = true
const GLFW_HAS_OSX_WINDOW_POS_FIX = true
const GLFW_HAS_NEW_CURSORS = false          # pending GLFW_jll@3.4
const GLFW_HAS_MOUSE_PASSTHROUGH = false    # pending GLFW_jll@3.4

const GLFW_WINDOW_DEFAULT_SIZE = Ref{Tuple{Int,Int}}((640,480))
const GLFW_WINDOW_DEFAULT_TITLE = Ref{String}("IMGUI")

const GLFW_BACKEND_PLATFORM_NAME = "julia_imgui_glfw"
