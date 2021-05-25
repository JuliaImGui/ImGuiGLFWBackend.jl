function ImGui_ImplGlfw_MouseButtonCallback(window::GLFW.Window, button::GLFW.MouseButton, action::GLFW.Action, mods::Cint)::Cvoid
    ctx_ptr::Ptr{Context} = ccall((:glfwGetWindowUserPointer, GLFW.libglfw), Ptr{Cvoid}, (GLFW.Window,), window)
    ctx = unsafe_pointer_to_objref(ctx_ptr)

    if ctx.PrevUserCallbackMousebutton != C_NULL
        ccall(ctx.PrevUserCallbackMousebutton, Cvoid, (GLFW.Window, GLFW.MouseButton, GLFW.Action, Cint), window, button, action, mods)
    end

    b = Cint(button)
    if action == GLFW.PRESS && b ≥ 0 && b < length(ctx.MouseJustPressed)
        ctx.MouseJustPressed[b+1] = true
    end

    return nothing
end

function ImGui_ImplGlfw_ScrollCallback(window::GLFW.Window, xoffset::Cdouble, yoffset::Cdouble)::Cvoid
    ctx_ptr::Ptr{Context} = ccall((:glfwGetWindowUserPointer, GLFW.libglfw), Ptr{Cvoid}, (GLFW.Window,), window)
    ctx = unsafe_pointer_to_objref(ctx_ptr)

    if ctx.PrevUserCallbackScroll != C_NULL
        ccall(ctx.PrevUserCallbackScroll, Cvoid, (GLFW.Window, Cdouble, Cdouble), window, xoffset, yoffset)
    end

    io::Ptr{ImGuiIO} = igGetIO()
    io.MouseWheelH = unsafe_load(io.MouseWheelH) + Cfloat(xoffset)
    io.MouseWheel = unsafe_load(io.MouseWheel) + Cfloat(yoffset)

    return nothing
end

function ImGui_ImplGlfw_KeyCallback(window::GLFW.Window, key, scancode, action, mods)::Cvoid
    ctx_ptr::Ptr{Context} = ccall((:glfwGetWindowUserPointer, GLFW.libglfw), Ptr{Cvoid}, (GLFW.Window,), window)
    ctx = unsafe_pointer_to_objref(ctx_ptr)

    if ctx.PrevUserCallbackKey != C_NULL
        ccall(ctx.PrevUserCallbackKey, Cvoid, (GLFW.Window, Cint, Cint, Cint, Cint), window, key, scancode, action, mods)
    end

    io::Ptr{ImGuiIO} = igGetIO()
    k = Cint(key)
    if k ≥ 0 && k < length(unsafe_load(io.KeysDown))
        if action == GLFW.PRESS
            c_set!(io.KeysDown, k, true)
            ctx.KeyOwnerWindows[k+1] = window
        end
        if action == GLFW.RELEASE
            c_set!(io.KeysDown, k, false)
            ctx.KeyOwnerWindows[k+1] = GLFW.Window(C_NULL)
        end
    end

    # modifiers are not reliable across systems
    io.KeyCtrl = c_get(io.KeysDown, GLFW.KEY_LEFT_CONTROL) || c_get(io.KeysDown, GLFW.KEY_RIGHT_CONTROL)
    io.KeyShift = c_get(io.KeysDown, GLFW.KEY_LEFT_SHIFT) || c_get(io.KeysDown, GLFW.KEY_RIGHT_SHIFT)
    io.KeyAlt = c_get(io.KeysDown, GLFW.KEY_LEFT_ALT) || c_get(io.KeysDown, GLFW.KEY_RIGHT_ALT)
    if Sys.iswindows()
        io.KeySuper = false
    else
        io.KeySuper = c_get(io.KeysDown, GLFW.KEY_LEFT_SUPER) || c_get(io.KeysDown, GLFW.KEY_RIGHT_SUPER)
    end

    return nothing
end

function ImGui_ImplGlfw_CharCallback(window::GLFW.Window, x)::Cvoid
    ctx_ptr::Ptr{Context} = ccall((:glfwGetWindowUserPointer, GLFW.libglfw), Ptr{Cvoid}, (GLFW.Window,), window)
    ctx = unsafe_pointer_to_objref(ctx_ptr)

    if ctx.PrevUserCallbackChar != C_NULL
        ccall(ctx.PrevUserCallbackChar, Cvoid, (GLFW.Window, Cuint), window, x)
    end

    0 < Cuint(x) < 0x10000 && ImGuiIO_AddInputCharacter(igGetIO(), x)

    return nothing
end

function ImGui_ImplGlfw_MonitorCallback(monitor::GLFW.Monitor, x::Cint)::Cvoid
    ctx_ptr::Ptr{Context} = ccall((:glfwGetWindowUserPointer, GLFW.libglfw), Ptr{Cvoid}, (GLFW.Window,), window)
    ctx = unsafe_pointer_to_objref(ctx_ptr)

    if ctx.PrevUserCallbackMonitor != C_NULL
        ccall(ctx.PrevUserCallbackMonitor, Cvoid, (GLFW.Window, Cint), window, x)
    end

    ctx.WantUpdateMonitors = true

    return nothing
end

function ImGui_ImplGlfw_WindowCloseCallback(window::GLFW.Window)::Cvoid
    viewport::Ptr{ImGuiViewport} = igFindViewportByPlatformHandle(window)
    if viewport != C_NULL
        viewport.PlatformRequestClose = true
    end
    return nothing
end

function ImGui_ImplGlfw_WindowPosCallback(window::GLFW.Window, x::Cint, y::Cint)::Cvoid
    viewport::Ptr{ImGuiViewport} = igFindViewportByPlatformHandle(window)
    if viewport != C_NULL
        data::Ptr{ImGuiViewportDataGlfw} = viewport.PlatformUserData
        if data != C_NULL
            ignore_event = igGetFrameCount() ≤ (unsafe_load(data.IgnoreWindowPosEventFrame) + 1)
            ignore_event && return nothing
        end
        viewport.PlatformRequestMove = true
    end
    return nothing
end

function ImGui_ImplGlfw_WindowSizeCallback(window::GLFW.Window, x::Cint, y::Cint)::Cvoid
    viewport::Ptr{ImGuiViewport} = igFindViewportByPlatformHandle(window)
    if viewport != C_NULL
        data::Ptr{ImGuiViewportDataGlfw} = viewport.PlatformUserData
        if data != C_NULL
            ignore_event = igGetFrameCount() ≤ (unsafe_load(data.IgnoreWindowSizeEventFrame) + 1)
            ignore_event && return nothing
        end
        viewport.PlatformRequestResize = true
    end
    return nothing
end
