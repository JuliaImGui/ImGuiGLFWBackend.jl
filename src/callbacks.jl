function ImGui_ImplGlfw_ErrorCallback(code::Cint, description::Ptr{Cchar})::Cvoid
    @error "GLFW ERROR: code $code msg: $(unsafe_string(description))"
    return nothing
end

function ImGui_ImplGlfw_MouseButtonCallback(window::Ptr{GLFWwindow}, button::Cint, action::Cint, mods::Cint)::Cvoid
    ctx = unsafe_pointer_to_objref(glfwGetWindowUserPointer(window))
    if ctx.PrevUserCallbackMousebutton != C_NULL
        ccall(ctx.PrevUserCallbackMousebutton, Cvoid, (Ptr{GLFWwindow}, Cint, Cint, Cint), window, button, action, mods)
    end

    if action == GLFW_PRESS && button ≥ 0 && button < length(ctx.MouseJustPressed)
        ctx.MouseJustPressed[button+1] = true
    end

    return nothing
end

function ImGui_ImplGlfw_ScrollCallback(window::Ptr{GLFWwindow}, xoffset::Cdouble, yoffset::Cdouble)::Cvoid
    ctx = unsafe_pointer_to_objref(glfwGetWindowUserPointer(window))
    if ctx.PrevUserCallbackScroll != C_NULL
        ccall(ctx.PrevUserCallbackScroll, Cvoid, (Ptr{GLFWwindow}, Cdouble, Cdouble), window, xoffset, yoffset)
    end

    io::Ptr{ImGuiIO} = igGetIO()
    io.MouseWheelH = unsafe_load(io.MouseWheelH) + Cfloat(xoffset)
    io.MouseWheel = unsafe_load(io.MouseWheel) + Cfloat(yoffset)

    return nothing
end

function ImGui_ImplGlfw_KeyCallback(window::Ptr{GLFWwindow}, key::Cint, scancode::Cint, action::Cint, mods::Cint)::Cvoid
    ctx = unsafe_pointer_to_objref(glfwGetWindowUserPointer(window))
    if ctx.PrevUserCallbackKey != C_NULL
        ccall(ctx.PrevUserCallbackKey, Cvoid, (Ptr{GLFWwindow}, Cint, Cint, Cint, Cint), window, key, scancode, action, mods)
    end

    io::Ptr{ImGuiIO} = igGetIO()
    if key ≥ 0 && key < length(unsafe_load(io.KeysDown))
        if action == GLFW_PRESS
            c_set!(io.KeysDown, key, true)
            ctx.KeyOwnerWindows[key+1] = window
        end
        if action == GLFW_RELEASE
            c_set!(io.KeysDown, key, false)
            ctx.KeyOwnerWindows[key+1] = C_NULL
        end
    end

    # modifiers are not reliable across systems
    io.KeyCtrl = c_get(io.KeysDown, GLFW_KEY_LEFT_CONTROL) || c_get(io.KeysDown, GLFW_KEY_RIGHT_CONTROL)
    io.KeyShift = c_get(io.KeysDown, GLFW_KEY_LEFT_SHIFT) || c_get(io.KeysDown, GLFW_KEY_RIGHT_SHIFT)
    io.KeyAlt = c_get(io.KeysDown, GLFW_KEY_LEFT_ALT) || c_get(io.KeysDown, GLFW_KEY_RIGHT_ALT)
    if Sys.iswindows()
        io.KeySuper = false
    else
        io.KeySuper = c_get(io.KeysDown, GLFW_KEY_LEFT_SUPER) || c_get(io.KeysDown, GLFW_KEY_RIGHT_SUPER)
    end

    return nothing
end

function ImGui_ImplGlfw_CharCallback(window::Ptr{GLFWwindow}, x::Cuint)::Cvoid
    ctx = unsafe_pointer_to_objref(glfwGetWindowUserPointer(window))
    if ctx.PrevUserCallbackChar != C_NULL
        ccall(ctx.PrevUserCallbackChar, Cvoid, (Ptr{GLFWwindow}, Cuint), window, x)
    end

    0 < x < 0x10000 && ImGuiIO_AddInputCharacter(igGetIO(), x)

    return nothing
end

function ImGui_ImplGlfw_MonitorCallback(monitor::Ptr{GLFWmonitor}, x::Cint)::Cvoid
    ctx.WantUpdateMonitors = true
    return nothing
end

function ImGui_ImplGlfw_WindowCloseCallback(window::Ptr{GLFWwindow})::Cvoid
    viewport::Ptr{ImGuiViewport} = igFindViewportByPlatformHandle(window)
    if viewport != C_NULL
        viewport.PlatformRequestClose = true
    end
    return nothing
end

function ImGui_ImplGlfw_WindowPosCallback(window::Ptr{GLFWwindow}, x::Cint, y::Cint)::Cvoid
    viewport::Ptr{ImGuiViewport} = igFindViewportByPlatformHandle(window)
    if viewport != C_NULL
        data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
        if data != C_NULL
            ignore_event = igGetFrameCount() ≤ (unsafe_load(data.IgnoreWindowPosEventFrame) + 1)
            ignore_event && return nothing
        end
        viewport.PlatformRequestMove = true
    end
    return nothing
end

function ImGui_ImplGlfw_WindowSizeCallback(window::Ptr{GLFWwindow}, x::Cint, y::Cint)::Cvoid
    viewport::Ptr{ImGuiViewport} = igFindViewportByPlatformHandle(window)
    if viewport != C_NULL
        data::Ptr{ImGuiViewportDataGlfw} = unsafe_load(viewport.PlatformUserData)
        if data != C_NULL
            ignore_event = igGetFrameCount() ≤ (unsafe_load(data.IgnoreWindowSizeEventFrame) + 1)
            ignore_event && return nothing
        end
        viewport.PlatformRequestResize = true
    end
    return nothing
end
