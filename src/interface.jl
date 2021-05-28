"""
    init(ctx::Context)
Initialize GLFW backend. Do initialize a IMGUI context before calling this function.
"""
function init(ctx::Context)
    ctx.Time = 0.0

    # setup back-end capabilities flags
    io::Ptr{ImGuiIO} = igGetIO()
    io.BackendFlags = unsafe_load(io.BackendFlags) | ImGuiBackendFlags_HasMouseCursors
    io.BackendFlags = unsafe_load(io.BackendFlags) | ImGuiBackendFlags_HasSetMousePos
    io.BackendFlags = unsafe_load(io.BackendFlags) | ImGuiBackendFlags_PlatformHasViewports
    # TODO: pending glfw 3.4
    # io.BackendFlags = unsafe_load(io.BackendFlags) | ImGuiBackendFlags_HasMouseHoveredViewport
    io.BackendPlatformName = pointer(GLFW_BACKEND_PLATFORM_NAME)

    # store the contextual object reference to IMGUI
    io.UserData = pointer_from_objref(ctx)

    # keyboard mapping
    c_set!(io.KeyMap, ImGuiKey_Tab, GLFW_KEY_TAB)
    c_set!(io.KeyMap, ImGuiKey_LeftArrow, GLFW_KEY_LEFT)
    c_set!(io.KeyMap, ImGuiKey_RightArrow, GLFW_KEY_RIGHT)
    c_set!(io.KeyMap, ImGuiKey_UpArrow, GLFW_KEY_UP)
    c_set!(io.KeyMap, ImGuiKey_DownArrow, GLFW_KEY_DOWN)
    c_set!(io.KeyMap, ImGuiKey_PageUp, GLFW_KEY_PAGE_UP)
    c_set!(io.KeyMap, ImGuiKey_PageDown, GLFW_KEY_PAGE_DOWN)
    c_set!(io.KeyMap, ImGuiKey_Home, GLFW_KEY_HOME)
    c_set!(io.KeyMap, ImGuiKey_End, GLFW_KEY_END)
    c_set!(io.KeyMap, ImGuiKey_Insert, GLFW_KEY_INSERT)
    c_set!(io.KeyMap, ImGuiKey_Delete, GLFW_KEY_DELETE)
    c_set!(io.KeyMap, ImGuiKey_Backspace, GLFW_KEY_BACKSPACE)
    c_set!(io.KeyMap, ImGuiKey_Space, GLFW_KEY_SPACE)
    c_set!(io.KeyMap, ImGuiKey_Enter, GLFW_KEY_ENTER)
    c_set!(io.KeyMap, ImGuiKey_Escape, GLFW_KEY_ESCAPE)
    c_set!(io.KeyMap, ImGuiKey_KeyPadEnter, GLFW_KEY_KP_ENTER)
    c_set!(io.KeyMap, ImGuiKey_A, GLFW_KEY_A)
    c_set!(io.KeyMap, ImGuiKey_C, GLFW_KEY_C)
    c_set!(io.KeyMap, ImGuiKey_V, GLFW_KEY_V)
    c_set!(io.KeyMap, ImGuiKey_X, GLFW_KEY_X)
    c_set!(io.KeyMap, ImGuiKey_Y, GLFW_KEY_Y)
    c_set!(io.KeyMap, ImGuiKey_Z, GLFW_KEY_Z)

    # set clipboard
    io.GetClipboardTextFn = GLFW_GET_CLIPBOARD_TEXT_FUNCPTR[]
    io.SetClipboardTextFn = GLFW_SET_CLIPBOARD_TEXT_FUNCPTR[]
    io.ClipboardUserData = Ptr{Cvoid}(ctx.Window)

    # create mouse cursors
    ctx.MouseCursors[ImGuiMouseCursor_Arrow+1] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_TextInput+1] = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeNS+1] = glfwCreateStandardCursor(GLFW_VRESIZE_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeEW+1] = glfwCreateStandardCursor(GLFW_HRESIZE_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_Hand+1] = glfwCreateStandardCursor(GLFW_HAND_CURSOR)

    # prepare for GLFW 3.4+
    # ctx.MouseCursors[ImGuiMouseCursor_ResizeAll+1] = glfwCreateStandardCursor(GLFW_RESIZE_ALL_CURSOR)
    # ctx.MouseCursors[ImGuiMouseCursor_ResizeNESW+1] = glfwCreateStandardCursor(GLFW_RESIZE_NESW_CURSOR)
    # ctx.MouseCursors[ImGuiMouseCursor_ResizeNWSE+1] = glfwCreateStandardCursor(GLFW_RESIZE_NWSE_CURSOR)
    # ctx.MouseCursors[ImGuiMouseCursor_NotAllowed+1] = glfwCreateStandardCursor(GLFW_NOT_ALLOWED_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeAll+1] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeNESW+1] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeNWSE+1] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_NotAllowed+1] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR)

    # chain GLFW callbacks
    ctx.PrevUserCallbackMousebutton = C_NULL
    ctx.PrevUserCallbackScroll = C_NULL
    ctx.PrevUserCallbackKey = C_NULL
    ctx.PrevUserCallbackChar = C_NULL
    ctx.PrevUserCallbackMonitor = C_NULL
    if ctx.InstalledCallbacks
        ctx.PrevUserCallbackMousebutton = glfwSetMouseButtonCallback(ctx.Window, @cfunction(ImGui_ImplGlfw_MouseButtonCallback, Cvoid, (Ptr{GLFWwindow}, Cint, Cint, Cint)))
        ctx.PrevUserCallbackScroll = glfwSetScrollCallback(ctx.Window, @cfunction(ImGui_ImplGlfw_ScrollCallback, Cvoid, (Ptr{GLFWwindow}, Cdouble, Cdouble)))
        ctx.PrevUserCallbackKey = glfwSetKeyCallback(ctx.Window, @cfunction(ImGui_ImplGlfw_KeyCallback, Cvoid, (Ptr{GLFWwindow}, Cint, Cint, Cint, Cint)))
        ctx.PrevUserCallbackChar = glfwSetCharCallback(ctx.Window, @cfunction(ImGui_ImplGlfw_CharCallback, Cvoid, (Ptr{GLFWwindow}, Cuint)))
        ctx.PrevUserCallbackMonitor = glfwSetMonitorCallback(@cfunction(ImGui_ImplGlfw_MonitorCallback, Cvoid, (Ptr{GLFWmonitor}, Cint)))
    end

    # update monitors the first time
    ImGui_ImplGlfw_UpdateMonitors(ctx)
    glfwSetMonitorCallback(@cfunction(ImGui_ImplGlfw_MonitorCallback, Cvoid, (Ptr{GLFWmonitor}, Cint)))

    # the mouse update function expect PlatformHandle to be filled for the main viewport
    main_viewport::Ptr{ImGuiViewport} = igGetMainViewport()
    main_viewport.PlatformHandle = Ptr{Cvoid}(ctx.Window)
    if Sys.iswindows()
        main_viewport.PlatformHandleRaw = ccall((:glfwGetWin32Window, GLFW.libglfw), Ptr{Cvoid}, (Ptr{Cvoid},), ctx.Window)
    end

    if unsafe_load(io.ConfigFlags) & ImGuiConfigFlags_ViewportsEnable == ImGuiConfigFlags_ViewportsEnable
        ImGui_ImplGlfw_InitPlatformInterface(ctx)
    end

    return true
end

"""
    shutdown((ctx::Context)
Clean up resources.
"""
function shutdown(ctx::Context)
    ImGui_ImplGlfw_ShutdownPlatformInterface(ctx)

    if ctx.InstalledCallbacks
        glfwSetMouseButtonCallback(ctx.Window, ctx.PrevUserCallbackMousebutton)
        glfwSetScrollCallback(ctx.Window, ctx.PrevUserCallbackScroll)
        glfwSetKeyCallback(ctx.Window, ctx.PrevUserCallbackKey)
        glfwSetCharCallback(ctx.Window, ctx.PrevUserCallbackChar)
        ctx.InstalledCallbacks = false
    end

    for cursor_n = 1:ImGuiMouseCursor_COUNT
        glfwDestroyCursor(ctx.MouseCursors[cursor_n])
        ctx.MouseCursors[cursor_n] = C_NULL
    end

    ctx.ClientApi = GlfwClientApi_Unknown

    return true
end

function ImGui_ImplGlfw_UpdateMousePosAndButtons(ctx::Context)
    # update buttons
    io::Ptr{ImGuiIO} = igGetIO()
    for n = 0:length(ctx.MouseJustPressed)-1
        # if a mouse press event came, always pass it as "mouse held this frame",
        # so we don't miss click-release events that are shorter than 1 frame.
        is_down = ctx.MouseJustPressed[n+1] || glfwGetMouseButton(ctx.Window, n) == GLFW_PRESS
        c_set!(io.MouseDown, n, is_down)
        ctx.MouseJustPressed[n+1] = false
    end

    # update mouse position
    mouse_pos_backup = unsafe_load(io.MousePos)
    FLT_MAX = igGET_FLT_MAX()
    io.MousePos = ImVec2(-FLT_MAX, -FLT_MAX)
    io.MouseHoveredViewport = 0
    platform_io::Ptr{ImGuiPlatformIO} = igGetPlatformIO()
    vp = unsafe_load(platform_io.Viewports)
    viewport_ptrs = unsafe_wrap(Vector{Ptr{ImGuiViewport}}, vp.Data, vp.Size)
    for viewport in viewport_ptrs
        window = unsafe_load(viewport.PlatformHandle)
        @assert window != C_NULL

        if glfwGetWindowAttrib(window, GLFW_FOCUSED) != 0
            if unsafe_load(io.WantSetMousePos)
                x = mouse_pos_backup.x - unsafe_load(viewport.Pos.x)
                y = mouse_pos_backup.y - unsafe_load(viewport.Pos.y)
                glfwSetCursorPos(window, Cdouble(x), Cdouble(y))
            else
                mouse_x, mouse_y = Cdouble(0), Cdouble(0)
                @c glfwGetCursorPos(window, &mouse_x, &mouse_y)
                if unsafe_load(io.ConfigFlags) & ImGuiConfigFlags_ViewportsEnable == ImGuiConfigFlags_ViewportsEnable
                    # Multi-viewport mode: mouse position in OS absolute coordinates (io.MousePos is (0,0) when the mouse is on the upper-left of the primary monitor)
                    window_x, window_y = Cint(0), Cint(0)
                    @c glfwGetWindowPos(window, &window_x, &window_y)
                    io.MousePos = ImVec2(Cfloat(mouse_x + window_x), Cfloat(mouse_y + window_y))
                else
                    # Single viewport mode: mouse position in client window coordinates (io.MousePos is (0,0) when the mouse is on the upper-left corner of the app window)
                    io.MousePos = ImVec2(Cfloat(mouse_x), Cfloat(mouse_y))
                end
            end

        end
        for n = 0:length(ctx.MouseJustPressed)-1
            c_set!(io.MouseDown, n, c_get(io.MouseDown, n) || glfwGetMouseButton(window, n) == GLFW_PRESS)
        end
    end
    # TODO: pending glfw 3.4 GLFW_HAS_MOUSE_PASSTHROUGH
    # TODO: _WIN32
end

function ImGui_ImplGlfw_UpdateMouseCursor(ctx::Context)
    io::Ptr{ImGuiIO} = igGetIO()
    if (unsafe_load(io.ConfigFlags) & ImGuiConfigFlags_NoMouseCursorChange == ImGuiConfigFlags_NoMouseCursorChange) ||
        glfwGetInputMode(ctx.Window, GLFW_CURSOR) == GLFW_CURSOR_DISABLED
        return nothing
    end

    imgui_cursor = igGetMouseCursor()
    platform_io::Ptr{ImGuiPlatformIO} = igGetPlatformIO()
    vp = unsafe_load(platform_io.Viewports)
    viewport_ptrs = unsafe_wrap(Vector{Ptr{ImGuiViewport}}, vp.Data, vp.Size)
    for viewport in viewport_ptrs
        window = unsafe_load(viewport.PlatformHandle)
        @assert window != C_NULL
        if imgui_cursor == ImGuiMouseCursor_None || unsafe_load(io.MouseDrawCursor)
            # hide OS mouse cursor if imgui is drawing it or if it wants no cursor
            glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN)
        else
            # show OS mouse cursor
            cursor = ctx.MouseCursors[imgui_cursor+1]
            glfwSetCursor(window, cursor != C_NULL ? ctx.MouseCursors[imgui_cursor+1] : ctx.MouseCursors[ImGuiMouseCursor_Arrow+1])
            glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL)
        end
    end

    return nothing
end

function ImGui_ImplGlfw_UpdateMonitors(ctx::Context)
    platform_io::Ptr{ImGuiPlatformIO} = igGetPlatformIO()
    monitors_count = Cint(0)
	ptr = @c glfwGetMonitors(&monitors_count)
	glfw_monitors = unsafe_wrap(Array, ptr, monitors_count)
    monitors_ptr::Ptr{ImGuiPlatformMonitor} = Libc.malloc(monitors_count * sizeof(ImGuiPlatformMonitor))
    for i = 1:monitors_count
        glfw_monitor = glfw_monitors[i]
        mptr::Ptr{ImGuiPlatformMonitor} = monitors_ptr + (i-1) * sizeof(ImGuiPlatformMonitor)

        x, y = Cint(0), Cint(0)
        @c glfwGetMonitorPos(glfw_monitor, &x, &y)
        vid_mode = unsafe_load(glfwGetVideoMode(glfw_monitor))
        mptr.MainPos = ImVec2(x, y)
        mptr.MainSize = ImVec2(vid_mode.width, vid_mode.height)
        mptr.WorkPos = ImVec2(x, y)
        mptr.WorkSize = ImVec2(vid_mode.width, vid_mode.height)

        w, h = Cint(0), Cint(0)
        @c glfwGetMonitorWorkarea(glfw_monitors[i], &x, &y, &w, &h)
        if w > 0 && h > 0
            mptr.WorkPos = ImVec2(Cfloat(x), Cfloat(y))
            mptr.WorkSize = ImVec2(Cfloat(w), Cfloat(h))
        end

        x_scale, y_scale = Cfloat(0), Cfloat(0)
        @c glfwGetMonitorContentScale(glfw_monitor, &x_scale, &y_scale)
        mptr.DpiScale = x_scale
    end

    platform_io.Monitors = ImVector_ImGuiPlatformMonitor(monitors_count, monitors_count, monitors_ptr)
    ctx.WantUpdateMonitors = false

    return nothing
end

function new_frame(ctx::Context)
    io::Ptr{ImGuiIO} = igGetIO()
    @assert ImFontAtlas_IsBuilt(unsafe_load(io.Fonts)) "Font atlas not built! It is generally built by the renderer back-end. Missing call to renderer _NewFrame() function? e.g. ImGui_ImplOpenGL3_NewFrame()."

    # setup display size (every frame to accommodate for window resizing)
    w, h = Cint(0), Cint(0)
    display_w, display_h = Cint(0), Cint(0)
    @c glfwGetWindowSize(ctx.Window, &w, &h)
    @c glfwGetFramebufferSize(ctx.Window, &display_w, &display_h)
    io.DisplaySize = ImVec2(Cfloat(w), Cfloat(h))
    if w > 0 && h > 0
        w_scale = Cfloat(display_w / w)
        h_scale = Cfloat(display_h / h)
        io.DisplayFramebufferScale = ImVec2(w_scale, h_scale)
    end

    ctx.WantUpdateMonitors && ImGui_ImplGlfw_UpdateMonitors(ctx)

    # setup time step
    current_time = glfwGetTime()
    io.DeltaTime = ctx.Time > 0.0 ? Cfloat(current_time - ctx.Time) : Cfloat(1.0/60.0)
    ctx.Time = current_time

    ImGui_ImplGlfw_UpdateMousePosAndButtons(ctx)
    ImGui_ImplGlfw_UpdateMouseCursor(ctx)

    # TODO: Gamepad navigation mapping
    # ImGui_ImplGlfw_UpdateGamepads()
end
