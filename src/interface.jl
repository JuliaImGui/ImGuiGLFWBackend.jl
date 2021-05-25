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
    c_set!(io.KeyMap, ImGuiKey_Tab, GLFW.KEY_TAB)
    c_set!(io.KeyMap, ImGuiKey_LeftArrow, GLFW.KEY_LEFT)
    c_set!(io.KeyMap, ImGuiKey_RightArrow, GLFW.KEY_RIGHT)
    c_set!(io.KeyMap, ImGuiKey_UpArrow, GLFW.KEY_UP)
    c_set!(io.KeyMap, ImGuiKey_DownArrow, GLFW.KEY_DOWN)
    c_set!(io.KeyMap, ImGuiKey_PageUp, GLFW.KEY_PAGE_UP)
    c_set!(io.KeyMap, ImGuiKey_PageDown, GLFW.KEY_PAGE_DOWN)
    c_set!(io.KeyMap, ImGuiKey_Home, GLFW.KEY_HOME)
    c_set!(io.KeyMap, ImGuiKey_End, GLFW.KEY_END)
    c_set!(io.KeyMap, ImGuiKey_Insert, GLFW.KEY_INSERT)
    c_set!(io.KeyMap, ImGuiKey_Delete, GLFW.KEY_DELETE)
    c_set!(io.KeyMap, ImGuiKey_Backspace, GLFW.KEY_BACKSPACE)
    c_set!(io.KeyMap, ImGuiKey_Space, GLFW.KEY_SPACE)
    c_set!(io.KeyMap, ImGuiKey_Enter, GLFW.KEY_ENTER)
    c_set!(io.KeyMap, ImGuiKey_Escape, GLFW.KEY_ESCAPE)
    c_set!(io.KeyMap, ImGuiKey_KeyPadEnter, GLFW.KEY_KP_ENTER)
    c_set!(io.KeyMap, ImGuiKey_A, GLFW.KEY_A)
    c_set!(io.KeyMap, ImGuiKey_C, GLFW.KEY_C)
    c_set!(io.KeyMap, ImGuiKey_V, GLFW.KEY_V)
    c_set!(io.KeyMap, ImGuiKey_X, GLFW.KEY_X)
    c_set!(io.KeyMap, ImGuiKey_Y, GLFW.KEY_Y)
    c_set!(io.KeyMap, ImGuiKey_Z, GLFW.KEY_Z)

    # set clipboard
    io.GetClipboardTextFn = GLFW_GET_CLIPBOARD_TEXT_FUNCPTR[]
    io.SetClipboardTextFn = GLFW_SET_CLIPBOARD_TEXT_FUNCPTR[]
    io.ClipboardUserData = Ptr{Cvoid}(ctx.Window.handle)

    # create mouse cursors
    ctx.MouseCursors[ImGuiMouseCursor_Arrow+1] = GLFW.CreateStandardCursor(GLFW.ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_TextInput+1] = GLFW.CreateStandardCursor(GLFW.IBEAM_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeNS+1] = GLFW.CreateStandardCursor(GLFW.VRESIZE_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeEW+1] = GLFW.CreateStandardCursor(GLFW.HRESIZE_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_Hand+1] = GLFW.CreateStandardCursor(GLFW.HAND_CURSOR)

    # prepare for GLFW 3.4+
    # ctx.MouseCursors[ImGuiMouseCursor_ResizeAll+1] = GLFW.CreateStandardCursor(GLFW.RESIZE_ALL_CURSOR)
    # ctx.MouseCursors[ImGuiMouseCursor_ResizeNESW+1] = GLFW.CreateStandardCursor(GLFW.RESIZE_NESW_CURSOR)
    # ctx.MouseCursors[ImGuiMouseCursor_ResizeNWSE+1] = GLFW.CreateStandardCursor(GLFW.RESIZE_NWSE_CURSOR)
    # ctx.MouseCursors[ImGuiMouseCursor_NotAllowed+1] = GLFW.CreateStandardCursor(GLFW.NOT_ALLOWED_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeAll+1] = GLFW.CreateStandardCursor(GLFW.ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeNESW+1] = GLFW.CreateStandardCursor(GLFW.ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_ResizeNWSE+1] = GLFW.CreateStandardCursor(GLFW.ARROW_CURSOR)
    ctx.MouseCursors[ImGuiMouseCursor_NotAllowed+1] = GLFW.CreateStandardCursor(GLFW.ARROW_CURSOR)

    # chain GLFW callbacks
    ctx.PrevUserCallbackMousebutton = C_NULL
    ctx.PrevUserCallbackScroll = C_NULL
    ctx.PrevUserCallbackKey = C_NULL
    ctx.PrevUserCallbackChar = C_NULL
    ctx.PrevUserCallbackMonitor = C_NULL
    if ctx.InstalledCallbacks
        ctx.PrevUserCallbackMousebutton = GLFW.SetMouseButtonCallback(window, ImGui_ImplGlfw_MouseButtonCallback)
        ctx.PrevUserCallbackScroll = GLFW.SetScrollCallback(window, ImGui_ImplGlfw_ScrollCallback)
        ctx.PrevUserCallbackKey = GLFW.SetKeyCallback(window, ImGui_ImplGlfw_KeyCallback)
        ctx.PrevUserCallbackChar = GLFW.SetCharCallback(window, ImGui_ImplGlfw_CharCallback)
        ctx.PrevUserCallbackMonitor = GLFW.SetMonitorCallback(window, ImGui_ImplGlfw_MonitorCallback)
    end

    # update monitors the first time
    ImGui_ImplGlfw_UpdateMonitors(ctx)
    GLFW.SetMonitorCallback(ImGui_ImplGlfw_MonitorCallback)

    # the mouse update function expect PlatformHandle to be filled for the main viewport
    main_viewport::Ptr{ImGuiViewport} = igGetMainViewport()
    main_viewport.PlatformHandle = Ptr{Cvoid}(ctx.Window.handle)
    if Sys.iswindows()
        main_viewport.PlatformHandleRaw = ccall((:glfwGetWin32Window, GLFW.libglfw), Ptr{Cvoid}, (Ptr{Cvoid},), ctx.Window.handle)
    end

    if unsafe_load(io.ConfigFlags) & ImGuiConfigFlags_ViewportsEnable != 0
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
        GLFW.SetMouseButtonCallback(window, ctx.PrevUserCallbackMousebutton)
        GLFW.SetScrollCallback(window, ctx.PrevUserCallbackScroll)
        GLFW.SetKeyCallback(window, ctx.PrevUserCallbackKey)
        GLFW.SetCharCallback(window, ctx.PrevUserCallbackChar)
        ctx.InstalledCallbacks = false
    end

    for cursor_n = 1:ImGuiMouseCursor_COUNT
        GLFW.DestroyCursor(ctx.MouseCursors[cursor_n])
        ctx.MouseCursors[cursor_n] = GLFW.Cursor(C_NULL)
    end

    ctx.ClientApi = GlfwClientApi_Unknown

    return true
end

function ImGui_ImplGlfw_UpdateMousePosAndButtons(ctx::Context)
    # update buttons
    io::Ptr{ImGuiIO} = igGetIO()
    for i = 1:length(ctx.MouseJustPressed)
        # if a mouse press event came, always pass it as "mouse held this frame",
        # so we don't miss click-release events that are shorter than 1 frame.
        mousedown = ctx.MouseJustPressed[i] || GLFW.GetMouseButton(ctx.Window, GLFW.MouseButton(i-1))
        c_set!(io.MouseDown, i-1, mousedown)
        ctx.MouseJustPressed[i] = false
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
        window = GLFW.Window(unsafe_load(viewport.PlatformHandle))
        @assert window.handle != C_NULL

        is_focused = GLFW.GetWindowAttrib(window, GLFW.FOCUSED) != 0
        if is_focused
            if unsafe_load(io.WantSetMousePos)
                x = mouse_pos_backup.x - unsafe_load(viewport.Pos.x)
                y = mouse_pos_backup.y - unsafe_load(viewport.Pos.y)
                GLFW.SetCursorPos(window, Cdouble(x), Cdouble(y))
            else
                mouse_x, mouse_y = GLFW.GetCursorPos(window)
                if unsafe_load(io.ConfigFlags) & ImGuiConfigFlags_ViewportsEnable != 0
                    # Multi-viewport mode: mouse position in OS absolute coordinates (io.MousePos is (0,0) when the mouse is on the upper-left of the primary monitor)
                    window_x, window_y = GLFW.GetWindowPos(window)
                    io.MousePos = ImVec2(Cfloat(mouse_x + window_x), Cfloat(mouse_y + window_y))
                else
                    # Single viewport mode: mouse position in client window coordinates (io.MousePos is (0,0) when the mouse is on the upper-left corner of the app window)
                    io.MousePos = ImVec2(Cfloat(mouse_x), Cfloat(mouse_y))
                end
            end

        end
        md = unsafe_load(io.MouseDown)
        for i = 0:length(md)-1
            c_set!(io.MouseDown, i, md[i+1] | GLFW.GetMouseButton(window, i))
        end
    end
    # TODO: pending glfw 3.4 GLFW_HAS_MOUSE_PASSTHROUGH
    # TODO: _WIN32
end

function ImGui_ImplGlfw_UpdateMouseCursor(ctx::Context)
    io::Ptr{ImGuiIO} = igGetIO()
    if (unsafe_load(io.ConfigFlags) & ImGuiConfigFlags_NoMouseCursorChange != 0) ||
        GLFW.GetInputMode(ctx.Window, GLFW.CURSOR) == GLFW.CURSOR_DISABLED
        return nothing
    end

    imgui_cursor = igGetMouseCursor()
    platform_io::Ptr{ImGuiPlatformIO} = igGetPlatformIO()
    vp = unsafe_load(platform_io.Viewports)
    viewport_ptrs = unsafe_wrap(Vector{Ptr{ImGuiViewport}}, vp.Data, vp.Size)
    for viewport in viewport_ptrs
        window = GLFW.Window(unsafe_load(viewport.PlatformHandle))
        @assert window.handle != C_NULL
        if imgui_cursor == ImGuiMouseCursor_None || unsafe_load(io.MouseDrawCursor)
            # hide OS mouse cursor if imgui is drawing it or if it wants no cursor
            GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_HIDDEN)
        else
            # show OS mouse cursor
            cursor = ctx.MouseCursors[imgui_cursor+1]
            GLFW.SetCursor(window, cursor.handle != C_NULL ? ctx.MouseCursors[imgui_cursor+1] : ctx.MouseCursors[ImGuiMouseCursor_Arrow+1])
            GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
        end
    end

    return nothing
end

function ImGui_ImplGlfw_UpdateMonitors(ctx::Context)
    # there is no exposed ImVector API, so we use a Julia vector instead.
    # the default pointer of that C ImVector is C_NULL, so here we are safe and no memory leak issues.
    empty!(ctx.Monitors)
    platform_io::Ptr{ImGuiPlatformIO} = igGetPlatformIO()
    glfw_monitors = GLFW.GetMonitors()
    for glfw_monitor in glfw_monitors
        x, y = GLFW.GetMonitorPos(glfw_monitor)
        vid_mode = GLFW.GetVideoMode(glfw_monitor)
        main_pos, work_pos = ImVec2(x, y), ImVec2(x, y)
        main_size, work_size = ImVec2(vid_mode.width, vid_mode.height), ImVec2(vid_mode.width, vid_mode.height)
        x_scale, y_scale = GLFW.GetMonitorContentScale(glfw_monitor)
        push!(ctx.Monitors, ImGuiPlatformMonitor(main_pos, main_size, work_pos, work_size, x_scale))
    end
    platform_io.Monitors = ImVector_ImGuiPlatformMonitor(length(ctx.Monitors), length(ctx.Monitors), pointer(ctx.Monitors))
    ctx.WantUpdateMonitors = false
    return nothing
end

function new_frame(ctx::Context)
    io::Ptr{ImGuiIO} = igGetIO()
    @assert ImFontAtlas_IsBuilt(unsafe_load(io.Fonts)) "Font atlas not built! It is generally built by the renderer back-end. Missing call to renderer _NewFrame() function? e.g. ImGui_ImplOpenGL3_NewFrame()."

    # setup display size (every frame to accommodate for window resizing)
    w, h = GLFW.GetWindowSize(ctx.Window)
    display_w, display_h = GLFW.GetFramebufferSize(ctx.Window)
    io.DisplaySize = ImVec2(Cfloat(w), Cfloat(h))
    if w > 0 && h > 0
        w_scale = Cfloat(display_w / w)
        h_scale = Cfloat(display_h / h)
        io.DisplayFramebufferScale = ImVec2(w_scale, h_scale)
    end

    ctx.WantUpdateMonitors && ImGui_ImplGlfw_UpdateMonitors(ctx)

    # setup time step
    current_time = ccall((:glfwGetTime, GLFW.libglfw), Cdouble, ())
    io.DeltaTime = ctx.Time > 0.0 ? Cfloat(current_time - ctx.Time) : Cfloat(1.0/60.0)
    ctx.Time = current_time

    ImGui_ImplGlfw_UpdateMousePosAndButtons(ctx)
    ImGui_ImplGlfw_UpdateMouseCursor(ctx)

    # TODO: Gamepad navigation mapping
    # ImGui_ImplGlfw_UpdateGamepads()
end
