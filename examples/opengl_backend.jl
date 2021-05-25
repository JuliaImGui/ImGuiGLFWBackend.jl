using ImGuiGLFWBackend
using ImGuiGLFWBackend.LibCImGui

glfw_ctx = ImGuiGLFWBackend.create_context()

imgui_ctx = igCreateContext(C_NULL)

io = igGetIO()
io.ConfigFlags = unsafe_load(io.ConfigFlags) | ImGuiConfigFlags_DockingEnable
io.ConfigFlags = unsafe_load(io.ConfigFlags) | ImGuiConfigFlags_ViewportsEnable

igStyleColorsDark(C_NULL)
