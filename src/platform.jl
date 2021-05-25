struct ImGuiViewportDataGlfw
    Window::Ptr{Cvoid}
    WindowOwned::Bool
    IgnoreWindowPosEventFrame::Cint
    IgnoreWindowSizeEventFrame::Cint
end

function Base.getproperty(x::Ptr{ImGuiViewportDataGlfw}, f::Symbol)
    f === :Window && return Ptr{Ptr{Cvoid}}(x + fieldoffset(ImGuiViewportDataGlfw,1))
    f === :WindowOwned && return Ptr{Bool}(x + fieldoffset(ImGuiViewportDataGlfw,2))
    f === :IgnoreWindowPosEventFrame && return Ptr{Cint}(x + fieldoffset(ImGuiViewportDataGlfw,3))
    f === :IgnoreWindowSizeEventFrame && return Ptr{Cint}(x + fieldoffset(ImGuiViewportDataGlfw,4))
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{ImGuiViewportDataGlfw}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function ImGui_ImplGlfw_CreateWindow(viewport::Ptr{ImGuiViewport})
    io::Ptr{ImGuiIO} = igGetIO()
    ctx = unsafe_pointer_to_objref(Ptr{Context}(unsafe_load(io.UserData)))

    data::Ptr{ImGuiViewportDataGlfw} = Libc.malloc(sizeof(ImGuiViewportDataGlfw))
    viewport.PlatformUserData = data

    GLFW.WindowHint(GLFW.VISIBLE, false)
    GLFW.WindowHint(GLFW.FOCUSED, false)
    GLFW.WindowHint(GLFW.FOCUS_ON_SHOW, false)
    GLFW.WindowHint(GLFW.DECORATED, (unsafe_load(viewport.Flags) & ImGuiViewportFlags_NoDecoration != 0) ? false : true)
    GLFW.WindowHint(GLFW.FLOATING, unsafe_load(viewport.Flags) & ImGuiViewportFlags_TopMost != 0)

    share_window = ctx.ClientApi == GlfwClientApi_OpenGL ? ctx.Window : GLFW.Window(C_NULL)
    window_size = unsafe_load(viewport.Size)
    wx, wy = trunc(Cint, window_size.x), trunc(Cint, window_size.y)
    data_Window = GLFW.CreateWindow(wx, wy, "No Title Yet", GLFW.Monitor(C_NULL), share_window)
    viewport.PlatformHandle = data_Window.handle
    if Sys.iswindows()
        viewport.PlatformHandleRaw = ccall((:glfwGetWin32Window, GLFW.libglfw), Ptr{Cvoid}, (GLFW.Window,), data_Window)
    end
    pos = unsafe_load(viewport.Pos)
    px, py = trunc(Cint, pos.x), trunc(Cint, pos.y)
    GLFW.SetWindowPos(data_Window, px, py)

    # install window userdata
    ccall((:glfwSetWindowUserPointer, GLFW.libglfw), Cvoid, (GLFW.Window, Ptr{Cvoid}), data_Window, io.UserData)

    # install callbacks
    # GLFW.SetMouseButtonCallback(data_Window, ImGui_ImplGlfw_MouseButtonCallback)
    # GLFW.SetScrollCallback(data_Window, ImGui_ImplGlfw_ScrollCallback)
    # GLFW.SetKeyCallback(data_Window, ImGui_ImplGlfw_KeyCallback)
    # GLFW.SetCharCallback(data_Window, ImGui_ImplGlfw_CharCallback)
    # GLFW.SetWindowCloseCallback(data_Window, ImGui_ImplGlfw_WindowCloseCallback)
    # GLFW.SetWindowPosCallback(data_Window, ImGui_ImplGlfw_WindowPosCallback)
    # GLFW.SetWindowSizeCallback(data_Window, ImGui_ImplGlfw_WindowSizeCallback)
    if ctx.ClientApi == GlfwClientApi_OpenGL
        GLFW.MakeContextCurrent(data_Window)
        GLFW.SwapInterval(0)
    end

    data.Window = data_Window.handle
    data.WindowOwned = true
    data.IgnoreWindowPosEventFrame = -1
    data.IgnoreWindowSizeEventFrame = -1

    return nothing
end

function ImGui_ImplGlfw_DestroyWindow(viewport::Ptr{ImGuiViewport})
    io::Ptr{ImGuiIO} = igGetIO()
    ctx = unsafe_pointer_to_objref(Ptr{Context}(unsafe_load(io.UserData)))

    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    if data != C_NULL
        if unsafe_load(data.WindowOwned)
            # release any keys that were pressed in the window being destroyed and are still held down,
            # because we will not receive any release events after window is destroyed.
            win = GLFW.Window(unsafe_load(data.Window))
            for i = 0:length(ctx.KeyOwnerWindows)-1
                if ctx.KeyOwnerWindows[i+1].handle == win.handle
                    ImGui_ImplGlfw_KeyCallback(win, i, 0, GLFW.RELEASE, 0)
                end
            end
            GLFW.DestroyWindow(win)
        end
        data.Window = C_NULL
        Libc.free(data)
    end

    viewport.PlatformUserData = C_NULL
    viewport.PlatformHandle = C_NULL

    return nothing
end

function ImGui_ImplGlfw_ShowWindow(viewport::Ptr{ImGuiViewport})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)

    if Sys.iswindows()
        # TODO: impl
    end

    GLFW.ShowWindow(GLFW.Window(unsafe_load(data.Window)))

    return nothing
end

function ImGui_ImplGlfw_GetWindowPos(viewport::Ptr{ImGuiViewport})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    x, y = GLFW.GetWindowPos(GLFW.Window(unsafe_load(data.Window)))
    return ImVec2(Cfloat(x), Cfloat(y))
end

function ImGui_ImplGlfw_SetWindowPos(viewport::Ptr{ImGuiViewport}, pos::ImVec2)
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    data.IgnoreWindowPosEventFrame = igGetFrameCount()
    x, y = trunc(Cint, pos.x), trunc(Cint, pos.y)
    GLFW.SetWindowPos(GLFW.Window(unsafe_load(data.Window)), x, y)
    return nothing
end

function ImGui_ImplGlfw_GetWindowSize(viewport::Ptr{ImGuiViewport})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    w, h = GLFW.GetWindowSize(GLFW.Window(unsafe_load(data.Window)))
    return ImVec2(Cfloat(w), Cfloat(h))
end

function ImGui_ImplGlfw_SetWindowSize(viewport::Ptr{ImGuiViewport}, size::ImVec2)
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    data.IgnoreWindowSizeEventFrame = igGetFrameCount()
    x, y = trunc(Cint, size.x), trunc(Cint, size.y)
    GLFW.SetWindowSize(GLFW.Window(unsafe_load(data.Window)), x, y)
    return nothing
end

function ImGui_ImplGlfw_SetWindowTitle(viewport::Ptr{ImGuiViewport}, title::Ptr{Cchar})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    ccall((:glfwSetWindowTitle, GLFW.libglfw), Cvoid, (GLFW.Window, Ptr{Cchar}), GLFW.Window(unsafe_load(data.Window)), title)
    return nothing
end

function ImGui_ImplGlfw_SetWindowFocus(viewport::Ptr{ImGuiViewport})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    GLFW.FocusWindow(GLFW.Window(unsafe_load(data.Window)))
    return nothing
end

function ImGui_ImplGlfw_GetWindowFocus(viewport::Ptr{ImGuiViewport})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    return GLFW.GetWindowAttrib(GLFW.Window(unsafe_load(data.Window)), GLFW.FOCUSED) != 0
end

function ImGui_ImplGlfw_GetWindowMinimized(viewport::Ptr{ImGuiViewport})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    return GLFW.GetWindowAttrib(GLFW.Window(unsafe_load(data.Window)), GLFW.ICONIFIED) != 0
end

function ImGui_ImplGlfw_SetWindowAlpha(viewport::Ptr{ImGuiViewport}, alpha::Cfloat)
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    GLFW.SetWindowOpacity(GLFW.Window(unsafe_load(data.Window)), alpha)
    return nothing
end

function ImGui_ImplGlfw_RenderWindow(viewport::Ptr{ImGuiViewport}, userdata::Ptr{Cvoid})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    # FIXME: pass through userdata(add a new field in ImGuiViewportDataGlfw)
    io::Ptr{ImGuiIO} = igGetIO()
    ctx = unsafe_pointer_to_objref(Ptr{Context}(unsafe_load(io.UserData)))
    if ctx.ClientApi == GlfwClientApi_OpenGL
        GLFW.MakeContextCurrent(GLFW.Window(unsafe_load(data.Window)))
    end
    return nothing
end

function ImGui_ImplGlfw_SwapBuffers(viewport::Ptr{ImGuiViewport}, userdata::Ptr{Cvoid})
    data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
    # FIXME: pass through userdata(add a new field in ImGuiViewportDataGlfw)
    io::Ptr{ImGuiIO} = igGetIO()
    ctx = unsafe_pointer_to_objref(Ptr{Context}(unsafe_load(io.UserData)))
    if ctx.ClientApi == GlfwClientApi_OpenGL
        GLFW.MakeContextCurrent(GLFW.Window(unsafe_load(data.Window)))
        GLFW.SwapBuffers(GLFW.Window(unsafe_load(data.Window)))
    end
    return nothing
end

function ImGui_ImplGlfw_InitPlatformInterface(ctx::Context)
    # register platform interface (will be coupled with a renderer interface)
    platform_io::Ptr{ImGuiPlatformIO} = igGetPlatformIO()
    platform_io.Platform_CreateWindow = @cfunction(ImGui_ImplGlfw_CreateWindow, Cvoid, (Ptr{ImGuiViewport},))
    platform_io.Platform_DestroyWindow = @cfunction(ImGui_ImplGlfw_DestroyWindow, Cvoid, (Ptr{ImGuiViewport},))
    platform_io.Platform_ShowWindow = @cfunction(ImGui_ImplGlfw_ShowWindow, Cvoid, (Ptr{ImGuiViewport},))
    platform_io.Platform_SetWindowPos = @cfunction(ImGui_ImplGlfw_SetWindowPos, Cvoid, (Ptr{ImGuiViewport}, ImVec2))
    platform_io.Platform_GetWindowPos = @cfunction(ImGui_ImplGlfw_GetWindowPos, ImVec2, (Ptr{ImGuiViewport},))
    platform_io.Platform_SetWindowSize = @cfunction(ImGui_ImplGlfw_SetWindowSize, Cvoid, (Ptr{ImGuiViewport}, ImVec2))
    platform_io.Platform_GetWindowSize = @cfunction(ImGui_ImplGlfw_GetWindowSize, ImVec2, (Ptr{ImGuiViewport},))
    platform_io.Platform_SetWindowFocus = @cfunction(ImGui_ImplGlfw_SetWindowFocus, Cvoid, (Ptr{ImGuiViewport},))
    platform_io.Platform_GetWindowFocus = @cfunction(ImGui_ImplGlfw_GetWindowFocus, Bool, (Ptr{ImGuiViewport},))
    platform_io.Platform_GetWindowMinimized = @cfunction(ImGui_ImplGlfw_GetWindowMinimized, Bool, (Ptr{ImGuiViewport},))
    platform_io.Platform_SetWindowTitle = @cfunction(ImGui_ImplGlfw_SetWindowTitle, Cvoid, (Ptr{ImGuiViewport}, Ptr{Cchar}))
    platform_io.Platform_RenderWindow = @cfunction(ImGui_ImplGlfw_RenderWindow, Cvoid, (Ptr{ImGuiViewport}, Ptr{Cvoid}))
    platform_io.Platform_SwapBuffers = @cfunction(ImGui_ImplGlfw_SwapBuffers, Cvoid, (Ptr{ImGuiViewport}, Ptr{Cvoid}))
    platform_io.Platform_SetWindowAlpha = @cfunction(ImGui_ImplGlfw_SetWindowAlpha, Cvoid, (Ptr{ImGuiViewport}, Cfloat))
    # TODO: support Vulkan
    # platform_io.Platform_CreateVkSurface = ImGui_ImplGlfw_CreateVkSurface;
    # TODO: support IME
    # platform_io.Platform_SetImeInputPos = ImGui_ImplWin32_SetImeInputPos;

    # register main window handle (which is owned by the main application, not by us)
    # this is mostly for simplicity and consistency, so that our code (e.g. mouse handling etc.) can use same logic for main and secondary viewports.
    main_viewport::Ptr{ImGuiViewport} = igGetMainViewport()
    data::Ptr{ImGuiViewportDataGlfw} = Libc.malloc(sizeof(ImGuiViewportDataGlfw))
    data.Window = ctx.Window.handle
    data.WindowOwned = false
    data.IgnoreWindowPosEventFrame = -1
    data.IgnoreWindowSizeEventFrame = -1
    main_viewport.PlatformUserData = data
    main_viewport.PlatformHandle = Ptr{Cvoid}(ctx.Window.handle)

    return nothing
end

ImGui_ImplGlfw_ShutdownPlatformInterface(ctx::Context) = nothing
