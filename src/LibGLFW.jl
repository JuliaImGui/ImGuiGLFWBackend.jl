module LibGLFW

using ..GLFW.GLFW_jll


# typedef void ( * GLFWglproc ) ( void )
const GLFWglproc = Ptr{Cvoid}

# typedef void ( * GLFWvkproc ) ( void )
const GLFWvkproc = Ptr{Cvoid}

mutable struct GLFWmonitor end

mutable struct GLFWwindow end

mutable struct GLFWcursor end

# typedef void ( * GLFWerrorfun ) ( int , const char * )
const GLFWerrorfun = Ptr{Cvoid}

# typedef void ( * GLFWwindowposfun ) ( GLFWwindow * , int , int )
const GLFWwindowposfun = Ptr{Cvoid}

# typedef void ( * GLFWwindowsizefun ) ( GLFWwindow * , int , int )
const GLFWwindowsizefun = Ptr{Cvoid}

# typedef void ( * GLFWwindowclosefun ) ( GLFWwindow * )
const GLFWwindowclosefun = Ptr{Cvoid}

# typedef void ( * GLFWwindowrefreshfun ) ( GLFWwindow * )
const GLFWwindowrefreshfun = Ptr{Cvoid}

# typedef void ( * GLFWwindowfocusfun ) ( GLFWwindow * , int )
const GLFWwindowfocusfun = Ptr{Cvoid}

# typedef void ( * GLFWwindowiconifyfun ) ( GLFWwindow * , int )
const GLFWwindowiconifyfun = Ptr{Cvoid}

# typedef void ( * GLFWwindowmaximizefun ) ( GLFWwindow * , int )
const GLFWwindowmaximizefun = Ptr{Cvoid}

# typedef void ( * GLFWframebuffersizefun ) ( GLFWwindow * , int , int )
const GLFWframebuffersizefun = Ptr{Cvoid}

# typedef void ( * GLFWwindowcontentscalefun ) ( GLFWwindow * , float , float )
const GLFWwindowcontentscalefun = Ptr{Cvoid}

# typedef void ( * GLFWmousebuttonfun ) ( GLFWwindow * , int , int , int )
const GLFWmousebuttonfun = Ptr{Cvoid}

# typedef void ( * GLFWcursorposfun ) ( GLFWwindow * , double , double )
const GLFWcursorposfun = Ptr{Cvoid}

# typedef void ( * GLFWcursorenterfun ) ( GLFWwindow * , int )
const GLFWcursorenterfun = Ptr{Cvoid}

# typedef void ( * GLFWscrollfun ) ( GLFWwindow * , double , double )
const GLFWscrollfun = Ptr{Cvoid}

# typedef void ( * GLFWkeyfun ) ( GLFWwindow * , int , int , int , int )
const GLFWkeyfun = Ptr{Cvoid}

# typedef void ( * GLFWcharfun ) ( GLFWwindow * , unsigned int )
const GLFWcharfun = Ptr{Cvoid}

# typedef void ( * GLFWcharmodsfun ) ( GLFWwindow * , unsigned int , int )
const GLFWcharmodsfun = Ptr{Cvoid}

# typedef void ( * GLFWdropfun ) ( GLFWwindow * , int , const char * [ ] )
const GLFWdropfun = Ptr{Cvoid}

# typedef void ( * GLFWmonitorfun ) ( GLFWmonitor * , int )
const GLFWmonitorfun = Ptr{Cvoid}

# typedef void ( * GLFWjoystickfun ) ( int , int )
const GLFWjoystickfun = Ptr{Cvoid}

struct GLFWvidmode
    width::Cint
    height::Cint
    redBits::Cint
    greenBits::Cint
    blueBits::Cint
    refreshRate::Cint
end

struct GLFWgammaramp
    red::Ptr{Cushort}
    green::Ptr{Cushort}
    blue::Ptr{Cushort}
    size::Cuint
end

struct GLFWimage
    width::Cint
    height::Cint
    pixels::Ptr{Cuchar}
end

struct GLFWgamepadstate
    buttons::NTuple{15, Cuchar}
    axes::NTuple{6, Cfloat}
end

function glfwInit()
    ccall((:glfwInit, libglfw), Cint, ())
end

function glfwTerminate()
    ccall((:glfwTerminate, libglfw), Cvoid, ())
end

function glfwInitHint(hint, value)
    ccall((:glfwInitHint, libglfw), Cvoid, (Cint, Cint), hint, value)
end

function glfwGetVersion(major, minor, rev)
    ccall((:glfwGetVersion, libglfw), Cvoid, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), major, minor, rev)
end

function glfwGetVersionString()
    ccall((:glfwGetVersionString, libglfw), Ptr{Cchar}, ())
end

function glfwGetError(description)
    ccall((:glfwGetError, libglfw), Cint, (Ptr{Ptr{Cchar}},), description)
end

function glfwSetErrorCallback(callback)
    ccall((:glfwSetErrorCallback, libglfw), GLFWerrorfun, (GLFWerrorfun,), callback)
end

function glfwGetMonitors(count)
    ccall((:glfwGetMonitors, libglfw), Ptr{Ptr{GLFWmonitor}}, (Ptr{Cint},), count)
end

function glfwGetPrimaryMonitor()
    ccall((:glfwGetPrimaryMonitor, libglfw), Ptr{GLFWmonitor}, ())
end

function glfwGetMonitorPos(monitor, xpos, ypos)
    ccall((:glfwGetMonitorPos, libglfw), Cvoid, (Ptr{GLFWmonitor}, Ptr{Cint}, Ptr{Cint}), monitor, xpos, ypos)
end

function glfwGetMonitorWorkarea(monitor, xpos, ypos, width, height)
    ccall((:glfwGetMonitorWorkarea, libglfw), Cvoid, (Ptr{GLFWmonitor}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), monitor, xpos, ypos, width, height)
end

function glfwGetMonitorPhysicalSize(monitor, widthMM, heightMM)
    ccall((:glfwGetMonitorPhysicalSize, libglfw), Cvoid, (Ptr{GLFWmonitor}, Ptr{Cint}, Ptr{Cint}), monitor, widthMM, heightMM)
end

function glfwGetMonitorContentScale(monitor, xscale, yscale)
    ccall((:glfwGetMonitorContentScale, libglfw), Cvoid, (Ptr{GLFWmonitor}, Ptr{Cfloat}, Ptr{Cfloat}), monitor, xscale, yscale)
end

function glfwGetMonitorName(monitor)
    ccall((:glfwGetMonitorName, libglfw), Ptr{Cchar}, (Ptr{GLFWmonitor},), monitor)
end

function glfwSetMonitorUserPointer(monitor, pointer)
    ccall((:glfwSetMonitorUserPointer, libglfw), Cvoid, (Ptr{GLFWmonitor}, Ptr{Cvoid}), monitor, pointer)
end

function glfwGetMonitorUserPointer(monitor)
    ccall((:glfwGetMonitorUserPointer, libglfw), Ptr{Cvoid}, (Ptr{GLFWmonitor},), monitor)
end

function glfwSetMonitorCallback(callback)
    ccall((:glfwSetMonitorCallback, libglfw), GLFWmonitorfun, (GLFWmonitorfun,), callback)
end

function glfwGetVideoModes(monitor, count)
    ccall((:glfwGetVideoModes, libglfw), Ptr{GLFWvidmode}, (Ptr{GLFWmonitor}, Ptr{Cint}), monitor, count)
end

function glfwGetVideoMode(monitor)
    ccall((:glfwGetVideoMode, libglfw), Ptr{GLFWvidmode}, (Ptr{GLFWmonitor},), monitor)
end

function glfwSetGamma(monitor, gamma)
    ccall((:glfwSetGamma, libglfw), Cvoid, (Ptr{GLFWmonitor}, Cfloat), monitor, gamma)
end

function glfwGetGammaRamp(monitor)
    ccall((:glfwGetGammaRamp, libglfw), Ptr{GLFWgammaramp}, (Ptr{GLFWmonitor},), monitor)
end

function glfwSetGammaRamp(monitor, ramp)
    ccall((:glfwSetGammaRamp, libglfw), Cvoid, (Ptr{GLFWmonitor}, Ptr{GLFWgammaramp}), monitor, ramp)
end

function glfwDefaultWindowHints()
    ccall((:glfwDefaultWindowHints, libglfw), Cvoid, ())
end

function glfwWindowHint(hint, value)
    ccall((:glfwWindowHint, libglfw), Cvoid, (Cint, Cint), hint, value)
end

function glfwWindowHintString(hint, value)
    ccall((:glfwWindowHintString, libglfw), Cvoid, (Cint, Ptr{Cchar}), hint, value)
end

function glfwCreateWindow(width, height, title, monitor, share)
    ccall((:glfwCreateWindow, libglfw), Ptr{GLFWwindow}, (Cint, Cint, Ptr{Cchar}, Ptr{GLFWmonitor}, Ptr{GLFWwindow}), width, height, title, monitor, share)
end

function glfwDestroyWindow(window)
    ccall((:glfwDestroyWindow, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwWindowShouldClose(window)
    ccall((:glfwWindowShouldClose, libglfw), Cint, (Ptr{GLFWwindow},), window)
end

function glfwSetWindowShouldClose(window, value)
    ccall((:glfwSetWindowShouldClose, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint), window, value)
end

function glfwSetWindowTitle(window, title)
    ccall((:glfwSetWindowTitle, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cchar}), window, title)
end

function glfwSetWindowIcon(window, count, images)
    ccall((:glfwSetWindowIcon, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint, Ptr{GLFWimage}), window, count, images)
end

function glfwGetWindowPos(window, xpos, ypos)
    ccall((:glfwGetWindowPos, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cint}, Ptr{Cint}), window, xpos, ypos)
end

function glfwSetWindowPos(window, xpos, ypos)
    ccall((:glfwSetWindowPos, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint, Cint), window, xpos, ypos)
end

function glfwGetWindowSize(window, width, height)
    ccall((:glfwGetWindowSize, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cint}, Ptr{Cint}), window, width, height)
end

function glfwSetWindowSizeLimits(window, minwidth, minheight, maxwidth, maxheight)
    ccall((:glfwSetWindowSizeLimits, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint, Cint, Cint, Cint), window, minwidth, minheight, maxwidth, maxheight)
end

function glfwSetWindowAspectRatio(window, numer, denom)
    ccall((:glfwSetWindowAspectRatio, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint, Cint), window, numer, denom)
end

function glfwSetWindowSize(window, width, height)
    ccall((:glfwSetWindowSize, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint, Cint), window, width, height)
end

function glfwGetFramebufferSize(window, width, height)
    ccall((:glfwGetFramebufferSize, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cint}, Ptr{Cint}), window, width, height)
end

function glfwGetWindowFrameSize(window, left, top, right, bottom)
    ccall((:glfwGetWindowFrameSize, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), window, left, top, right, bottom)
end

function glfwGetWindowContentScale(window, xscale, yscale)
    ccall((:glfwGetWindowContentScale, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cfloat}, Ptr{Cfloat}), window, xscale, yscale)
end

function glfwGetWindowOpacity(window)
    ccall((:glfwGetWindowOpacity, libglfw), Cfloat, (Ptr{GLFWwindow},), window)
end

function glfwSetWindowOpacity(window, opacity)
    ccall((:glfwSetWindowOpacity, libglfw), Cvoid, (Ptr{GLFWwindow}, Cfloat), window, opacity)
end

function glfwIconifyWindow(window)
    ccall((:glfwIconifyWindow, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwRestoreWindow(window)
    ccall((:glfwRestoreWindow, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwMaximizeWindow(window)
    ccall((:glfwMaximizeWindow, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwShowWindow(window)
    ccall((:glfwShowWindow, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwHideWindow(window)
    ccall((:glfwHideWindow, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwFocusWindow(window)
    ccall((:glfwFocusWindow, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwRequestWindowAttention(window)
    ccall((:glfwRequestWindowAttention, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwGetWindowMonitor(window)
    ccall((:glfwGetWindowMonitor, libglfw), Ptr{GLFWmonitor}, (Ptr{GLFWwindow},), window)
end

function glfwSetWindowMonitor(window, monitor, xpos, ypos, width, height, refreshRate)
    ccall((:glfwSetWindowMonitor, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{GLFWmonitor}, Cint, Cint, Cint, Cint, Cint), window, monitor, xpos, ypos, width, height, refreshRate)
end

function glfwGetWindowAttrib(window, attrib)
    ccall((:glfwGetWindowAttrib, libglfw), Cint, (Ptr{GLFWwindow}, Cint), window, attrib)
end

function glfwSetWindowAttrib(window, attrib, value)
    ccall((:glfwSetWindowAttrib, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint, Cint), window, attrib, value)
end

function glfwSetWindowUserPointer(window, pointer)
    ccall((:glfwSetWindowUserPointer, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cvoid}), window, pointer)
end

function glfwGetWindowUserPointer(window)
    ccall((:glfwGetWindowUserPointer, libglfw), Ptr{Cvoid}, (Ptr{GLFWwindow},), window)
end

function glfwSetWindowPosCallback(window, callback)
    ccall((:glfwSetWindowPosCallback, libglfw), GLFWwindowposfun, (Ptr{GLFWwindow}, GLFWwindowposfun), window, callback)
end

function glfwSetWindowSizeCallback(window, callback)
    ccall((:glfwSetWindowSizeCallback, libglfw), GLFWwindowsizefun, (Ptr{GLFWwindow}, GLFWwindowsizefun), window, callback)
end

function glfwSetWindowCloseCallback(window, callback)
    ccall((:glfwSetWindowCloseCallback, libglfw), GLFWwindowclosefun, (Ptr{GLFWwindow}, GLFWwindowclosefun), window, callback)
end

function glfwSetWindowRefreshCallback(window, callback)
    ccall((:glfwSetWindowRefreshCallback, libglfw), GLFWwindowrefreshfun, (Ptr{GLFWwindow}, GLFWwindowrefreshfun), window, callback)
end

function glfwSetWindowFocusCallback(window, callback)
    ccall((:glfwSetWindowFocusCallback, libglfw), GLFWwindowfocusfun, (Ptr{GLFWwindow}, GLFWwindowfocusfun), window, callback)
end

function glfwSetWindowIconifyCallback(window, callback)
    ccall((:glfwSetWindowIconifyCallback, libglfw), GLFWwindowiconifyfun, (Ptr{GLFWwindow}, GLFWwindowiconifyfun), window, callback)
end

function glfwSetWindowMaximizeCallback(window, callback)
    ccall((:glfwSetWindowMaximizeCallback, libglfw), GLFWwindowmaximizefun, (Ptr{GLFWwindow}, GLFWwindowmaximizefun), window, callback)
end

function glfwSetFramebufferSizeCallback(window, callback)
    ccall((:glfwSetFramebufferSizeCallback, libglfw), GLFWframebuffersizefun, (Ptr{GLFWwindow}, GLFWframebuffersizefun), window, callback)
end

function glfwSetWindowContentScaleCallback(window, callback)
    ccall((:glfwSetWindowContentScaleCallback, libglfw), GLFWwindowcontentscalefun, (Ptr{GLFWwindow}, GLFWwindowcontentscalefun), window, callback)
end

function glfwPollEvents()
    ccall((:glfwPollEvents, libglfw), Cvoid, ())
end

function glfwWaitEvents()
    ccall((:glfwWaitEvents, libglfw), Cvoid, ())
end

function glfwWaitEventsTimeout(timeout)
    ccall((:glfwWaitEventsTimeout, libglfw), Cvoid, (Cdouble,), timeout)
end

function glfwPostEmptyEvent()
    ccall((:glfwPostEmptyEvent, libglfw), Cvoid, ())
end

function glfwGetInputMode(window, mode)
    ccall((:glfwGetInputMode, libglfw), Cint, (Ptr{GLFWwindow}, Cint), window, mode)
end

function glfwSetInputMode(window, mode, value)
    ccall((:glfwSetInputMode, libglfw), Cvoid, (Ptr{GLFWwindow}, Cint, Cint), window, mode, value)
end

function glfwRawMouseMotionSupported()
    ccall((:glfwRawMouseMotionSupported, libglfw), Cint, ())
end

function glfwGetKeyName(key, scancode)
    ccall((:glfwGetKeyName, libglfw), Ptr{Cchar}, (Cint, Cint), key, scancode)
end

function glfwGetKeyScancode(key)
    ccall((:glfwGetKeyScancode, libglfw), Cint, (Cint,), key)
end

function glfwGetKey(window, key)
    ccall((:glfwGetKey, libglfw), Cint, (Ptr{GLFWwindow}, Cint), window, key)
end

function glfwGetMouseButton(window, button)
    ccall((:glfwGetMouseButton, libglfw), Cint, (Ptr{GLFWwindow}, Cint), window, button)
end

function glfwGetCursorPos(window, xpos, ypos)
    ccall((:glfwGetCursorPos, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cdouble}, Ptr{Cdouble}), window, xpos, ypos)
end

function glfwSetCursorPos(window, xpos, ypos)
    ccall((:glfwSetCursorPos, libglfw), Cvoid, (Ptr{GLFWwindow}, Cdouble, Cdouble), window, xpos, ypos)
end

function glfwCreateCursor(image, xhot, yhot)
    ccall((:glfwCreateCursor, libglfw), Ptr{GLFWcursor}, (Ptr{GLFWimage}, Cint, Cint), image, xhot, yhot)
end

function glfwCreateStandardCursor(shape)
    ccall((:glfwCreateStandardCursor, libglfw), Ptr{GLFWcursor}, (Cint,), shape)
end

function glfwDestroyCursor(cursor)
    ccall((:glfwDestroyCursor, libglfw), Cvoid, (Ptr{GLFWcursor},), cursor)
end

function glfwSetCursor(window, cursor)
    ccall((:glfwSetCursor, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{GLFWcursor}), window, cursor)
end

function glfwSetKeyCallback(window, callback)
    ccall((:glfwSetKeyCallback, libglfw), GLFWkeyfun, (Ptr{GLFWwindow}, GLFWkeyfun), window, callback)
end

function glfwSetCharCallback(window, callback)
    ccall((:glfwSetCharCallback, libglfw), GLFWcharfun, (Ptr{GLFWwindow}, GLFWcharfun), window, callback)
end

function glfwSetCharModsCallback(window, callback)
    ccall((:glfwSetCharModsCallback, libglfw), GLFWcharmodsfun, (Ptr{GLFWwindow}, GLFWcharmodsfun), window, callback)
end

function glfwSetMouseButtonCallback(window, callback)
    ccall((:glfwSetMouseButtonCallback, libglfw), GLFWmousebuttonfun, (Ptr{GLFWwindow}, GLFWmousebuttonfun), window, callback)
end

function glfwSetCursorPosCallback(window, callback)
    ccall((:glfwSetCursorPosCallback, libglfw), GLFWcursorposfun, (Ptr{GLFWwindow}, GLFWcursorposfun), window, callback)
end

function glfwSetCursorEnterCallback(window, callback)
    ccall((:glfwSetCursorEnterCallback, libglfw), GLFWcursorenterfun, (Ptr{GLFWwindow}, GLFWcursorenterfun), window, callback)
end

function glfwSetScrollCallback(window, callback)
    ccall((:glfwSetScrollCallback, libglfw), GLFWscrollfun, (Ptr{GLFWwindow}, GLFWscrollfun), window, callback)
end

function glfwSetDropCallback(window, callback)
    ccall((:glfwSetDropCallback, libglfw), GLFWdropfun, (Ptr{GLFWwindow}, GLFWdropfun), window, callback)
end

function glfwJoystickPresent(jid)
    ccall((:glfwJoystickPresent, libglfw), Cint, (Cint,), jid)
end

function glfwGetJoystickAxes(jid, count)
    ccall((:glfwGetJoystickAxes, libglfw), Ptr{Cfloat}, (Cint, Ptr{Cint}), jid, count)
end

function glfwGetJoystickButtons(jid, count)
    ccall((:glfwGetJoystickButtons, libglfw), Ptr{Cuchar}, (Cint, Ptr{Cint}), jid, count)
end

function glfwGetJoystickHats(jid, count)
    ccall((:glfwGetJoystickHats, libglfw), Ptr{Cuchar}, (Cint, Ptr{Cint}), jid, count)
end

function glfwGetJoystickName(jid)
    ccall((:glfwGetJoystickName, libglfw), Ptr{Cchar}, (Cint,), jid)
end

function glfwGetJoystickGUID(jid)
    ccall((:glfwGetJoystickGUID, libglfw), Ptr{Cchar}, (Cint,), jid)
end

function glfwSetJoystickUserPointer(jid, pointer)
    ccall((:glfwSetJoystickUserPointer, libglfw), Cvoid, (Cint, Ptr{Cvoid}), jid, pointer)
end

function glfwGetJoystickUserPointer(jid)
    ccall((:glfwGetJoystickUserPointer, libglfw), Ptr{Cvoid}, (Cint,), jid)
end

function glfwJoystickIsGamepad(jid)
    ccall((:glfwJoystickIsGamepad, libglfw), Cint, (Cint,), jid)
end

function glfwSetJoystickCallback(callback)
    ccall((:glfwSetJoystickCallback, libglfw), GLFWjoystickfun, (GLFWjoystickfun,), callback)
end

function glfwUpdateGamepadMappings(string)
    ccall((:glfwUpdateGamepadMappings, libglfw), Cint, (Ptr{Cchar},), string)
end

function glfwGetGamepadName(jid)
    ccall((:glfwGetGamepadName, libglfw), Ptr{Cchar}, (Cint,), jid)
end

function glfwGetGamepadState(jid, state)
    ccall((:glfwGetGamepadState, libglfw), Cint, (Cint, Ptr{GLFWgamepadstate}), jid, state)
end

function glfwSetClipboardString(window, string)
    ccall((:glfwSetClipboardString, libglfw), Cvoid, (Ptr{GLFWwindow}, Ptr{Cchar}), window, string)
end

function glfwGetClipboardString(window)
    ccall((:glfwGetClipboardString, libglfw), Ptr{Cchar}, (Ptr{GLFWwindow},), window)
end

function glfwGetTime()
    ccall((:glfwGetTime, libglfw), Cdouble, ())
end

function glfwSetTime(time)
    ccall((:glfwSetTime, libglfw), Cvoid, (Cdouble,), time)
end

function glfwGetTimerValue()
    ccall((:glfwGetTimerValue, libglfw), UInt64, ())
end

function glfwGetTimerFrequency()
    ccall((:glfwGetTimerFrequency, libglfw), UInt64, ())
end

function glfwMakeContextCurrent(window)
    ccall((:glfwMakeContextCurrent, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwGetCurrentContext()
    ccall((:glfwGetCurrentContext, libglfw), Ptr{GLFWwindow}, ())
end

function glfwSwapBuffers(window)
    ccall((:glfwSwapBuffers, libglfw), Cvoid, (Ptr{GLFWwindow},), window)
end

function glfwSwapInterval(interval)
    ccall((:glfwSwapInterval, libglfw), Cvoid, (Cint,), interval)
end

function glfwExtensionSupported(extension)
    ccall((:glfwExtensionSupported, libglfw), Cint, (Ptr{Cchar},), extension)
end

function glfwGetProcAddress(procname)
    ccall((:glfwGetProcAddress, libglfw), GLFWglproc, (Ptr{Cchar},), procname)
end

function glfwVulkanSupported()
    ccall((:glfwVulkanSupported, libglfw), Cint, ())
end

function glfwGetRequiredInstanceExtensions(count)
    ccall((:glfwGetRequiredInstanceExtensions, libglfw), Ptr{Ptr{Cchar}}, (Ptr{UInt32},), count)
end

const GLFW_VERSION_MAJOR = 3

const GLFW_VERSION_MINOR = 3

const GLFW_VERSION_REVISION = 4

const GLFW_TRUE = 1

const GLFW_FALSE = 0

const GLFW_RELEASE = 0

const GLFW_PRESS = 1

const GLFW_REPEAT = 2

const GLFW_HAT_CENTERED = 0

const GLFW_HAT_UP = 1

const GLFW_HAT_RIGHT = 2

const GLFW_HAT_DOWN = 4

const GLFW_HAT_LEFT = 8

const GLFW_HAT_RIGHT_UP = GLFW_HAT_RIGHT | GLFW_HAT_UP

const GLFW_HAT_RIGHT_DOWN = GLFW_HAT_RIGHT | GLFW_HAT_DOWN

const GLFW_HAT_LEFT_UP = GLFW_HAT_LEFT | GLFW_HAT_UP

const GLFW_HAT_LEFT_DOWN = GLFW_HAT_LEFT | GLFW_HAT_DOWN

const GLFW_KEY_UNKNOWN = -1

const GLFW_KEY_SPACE = 32

const GLFW_KEY_APOSTROPHE = 39

const GLFW_KEY_COMMA = 44

const GLFW_KEY_MINUS = 45

const GLFW_KEY_PERIOD = 46

const GLFW_KEY_SLASH = 47

const GLFW_KEY_0 = 48

const GLFW_KEY_1 = 49

const GLFW_KEY_2 = 50

const GLFW_KEY_3 = 51

const GLFW_KEY_4 = 52

const GLFW_KEY_5 = 53

const GLFW_KEY_6 = 54

const GLFW_KEY_7 = 55

const GLFW_KEY_8 = 56

const GLFW_KEY_9 = 57

const GLFW_KEY_SEMICOLON = 59

const GLFW_KEY_EQUAL = 61

const GLFW_KEY_A = 65

const GLFW_KEY_B = 66

const GLFW_KEY_C = 67

const GLFW_KEY_D = 68

const GLFW_KEY_E = 69

const GLFW_KEY_F = 70

const GLFW_KEY_G = 71

const GLFW_KEY_I = 73

const GLFW_KEY_J = 74

const GLFW_KEY_K = 75

const GLFW_KEY_L = 76

const GLFW_KEY_M = 77

const GLFW_KEY_N = 78

const GLFW_KEY_O = 79

const GLFW_KEY_P = 80

const GLFW_KEY_Q = 81

const GLFW_KEY_R = 82

const GLFW_KEY_S = 83

const GLFW_KEY_T = 84

const GLFW_KEY_U = 85

const GLFW_KEY_V = 86

const GLFW_KEY_W = 87

const GLFW_KEY_X = 88

const GLFW_KEY_Y = 89

const GLFW_KEY_Z = 90

const GLFW_KEY_LEFT_BRACKET = 91

const GLFW_KEY_BACKSLASH = 92

const GLFW_KEY_RIGHT_BRACKET = 93

const GLFW_KEY_GRAVE_ACCENT = 96

const GLFW_KEY_WORLD_1 = 161

const GLFW_KEY_WORLD_2 = 162

const GLFW_KEY_ESCAPE = 256

const GLFW_KEY_ENTER = 257

const GLFW_KEY_TAB = 258

const GLFW_KEY_BACKSPACE = 259

const GLFW_KEY_INSERT = 260

const GLFW_KEY_DELETE = 261

const GLFW_KEY_RIGHT = 262

const GLFW_KEY_LEFT = 263

const GLFW_KEY_DOWN = 264

const GLFW_KEY_UP = 265

const GLFW_KEY_PAGE_UP = 266

const GLFW_KEY_PAGE_DOWN = 267

const GLFW_KEY_HOME = 268

const GLFW_KEY_END = 269

const GLFW_KEY_CAPS_LOCK = 280

const GLFW_KEY_SCROLL_LOCK = 281

const GLFW_KEY_NUM_LOCK = 282

const GLFW_KEY_PRINT_SCREEN = 283

const GLFW_KEY_PAUSE = 284

const GLFW_KEY_F1 = 290

const GLFW_KEY_F2 = 291

const GLFW_KEY_F3 = 292

const GLFW_KEY_F4 = 293

const GLFW_KEY_F5 = 294

const GLFW_KEY_F6 = 295

const GLFW_KEY_F7 = 296

const GLFW_KEY_F8 = 297

const GLFW_KEY_F9 = 298

const GLFW_KEY_F10 = 299

const GLFW_KEY_F11 = 300

const GLFW_KEY_F12 = 301

const GLFW_KEY_F13 = 302

const GLFW_KEY_F14 = 303

const GLFW_KEY_F15 = 304

const GLFW_KEY_F16 = 305

const GLFW_KEY_F17 = 306

const GLFW_KEY_F18 = 307

const GLFW_KEY_F19 = 308

const GLFW_KEY_F20 = 309

const GLFW_KEY_F21 = 310

const GLFW_KEY_F22 = 311

const GLFW_KEY_F23 = 312

const GLFW_KEY_F24 = 313

const GLFW_KEY_F25 = 314

const GLFW_KEY_KP_0 = 320

const GLFW_KEY_KP_1 = 321

const GLFW_KEY_KP_2 = 322

const GLFW_KEY_KP_3 = 323

const GLFW_KEY_KP_4 = 324

const GLFW_KEY_KP_5 = 325

const GLFW_KEY_KP_6 = 326

const GLFW_KEY_KP_7 = 327

const GLFW_KEY_KP_8 = 328

const GLFW_KEY_KP_9 = 329

const GLFW_KEY_KP_DECIMAL = 330

const GLFW_KEY_KP_DIVIDE = 331

const GLFW_KEY_KP_MULTIPLY = 332

const GLFW_KEY_KP_SUBTRACT = 333

const GLFW_KEY_KP_ADD = 334

const GLFW_KEY_KP_ENTER = 335

const GLFW_KEY_KP_EQUAL = 336

const GLFW_KEY_LEFT_SHIFT = 340

const GLFW_KEY_LEFT_CONTROL = 341

const GLFW_KEY_LEFT_ALT = 342

const GLFW_KEY_LEFT_SUPER = 343

const GLFW_KEY_RIGHT_SHIFT = 344

const GLFW_KEY_RIGHT_CONTROL = 345

const GLFW_KEY_RIGHT_ALT = 346

const GLFW_KEY_RIGHT_SUPER = 347

const GLFW_KEY_MENU = 348

const GLFW_KEY_LAST = GLFW_KEY_MENU

const GLFW_MOD_SHIFT = 0x0001

const GLFW_MOD_CONTROL = 0x0002

const GLFW_MOD_ALT = 0x0004

const GLFW_MOD_SUPER = 0x0008

const GLFW_MOD_CAPS_LOCK = 0x0010

const GLFW_MOD_NUM_LOCK = 0x0020

const GLFW_MOUSE_BUTTON_1 = 0

const GLFW_MOUSE_BUTTON_2 = 1

const GLFW_MOUSE_BUTTON_3 = 2

const GLFW_MOUSE_BUTTON_4 = 3

const GLFW_MOUSE_BUTTON_5 = 4

const GLFW_MOUSE_BUTTON_6 = 5

const GLFW_MOUSE_BUTTON_7 = 6

const GLFW_MOUSE_BUTTON_8 = 7

const GLFW_MOUSE_BUTTON_LAST = GLFW_MOUSE_BUTTON_8

const GLFW_MOUSE_BUTTON_LEFT = GLFW_MOUSE_BUTTON_1

const GLFW_MOUSE_BUTTON_RIGHT = GLFW_MOUSE_BUTTON_2

const GLFW_MOUSE_BUTTON_MIDDLE = GLFW_MOUSE_BUTTON_3

const GLFW_JOYSTICK_1 = 0

const GLFW_JOYSTICK_2 = 1

const GLFW_JOYSTICK_3 = 2

const GLFW_JOYSTICK_4 = 3

const GLFW_JOYSTICK_5 = 4

const GLFW_JOYSTICK_6 = 5

const GLFW_JOYSTICK_7 = 6

const GLFW_JOYSTICK_8 = 7

const GLFW_JOYSTICK_9 = 8

const GLFW_JOYSTICK_10 = 9

const GLFW_JOYSTICK_11 = 10

const GLFW_JOYSTICK_12 = 11

const GLFW_JOYSTICK_13 = 12

const GLFW_JOYSTICK_14 = 13

const GLFW_JOYSTICK_15 = 14

const GLFW_JOYSTICK_16 = 15

const GLFW_JOYSTICK_LAST = GLFW_JOYSTICK_16

const GLFW_GAMEPAD_BUTTON_A = 0

const GLFW_GAMEPAD_BUTTON_B = 1

const GLFW_GAMEPAD_BUTTON_X = 2

const GLFW_GAMEPAD_BUTTON_Y = 3

const GLFW_GAMEPAD_BUTTON_LEFT_BUMPER = 4

const GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER = 5

const GLFW_GAMEPAD_BUTTON_BACK = 6

const GLFW_GAMEPAD_BUTTON_START = 7

const GLFW_GAMEPAD_BUTTON_GUIDE = 8

const GLFW_GAMEPAD_BUTTON_LEFT_THUMB = 9

const GLFW_GAMEPAD_BUTTON_RIGHT_THUMB = 10

const GLFW_GAMEPAD_BUTTON_DPAD_UP = 11

const GLFW_GAMEPAD_BUTTON_DPAD_RIGHT = 12

const GLFW_GAMEPAD_BUTTON_DPAD_DOWN = 13

const GLFW_GAMEPAD_BUTTON_DPAD_LEFT = 14

const GLFW_GAMEPAD_BUTTON_LAST = GLFW_GAMEPAD_BUTTON_DPAD_LEFT

const GLFW_GAMEPAD_BUTTON_CROSS = GLFW_GAMEPAD_BUTTON_A

const GLFW_GAMEPAD_BUTTON_CIRCLE = GLFW_GAMEPAD_BUTTON_B

const GLFW_GAMEPAD_BUTTON_SQUARE = GLFW_GAMEPAD_BUTTON_X

const GLFW_GAMEPAD_BUTTON_TRIANGLE = GLFW_GAMEPAD_BUTTON_Y

const GLFW_GAMEPAD_AXIS_LEFT_X = 0

const GLFW_GAMEPAD_AXIS_LEFT_Y = 1

const GLFW_GAMEPAD_AXIS_RIGHT_X = 2

const GLFW_GAMEPAD_AXIS_RIGHT_Y = 3

const GLFW_GAMEPAD_AXIS_LEFT_TRIGGER = 4

const GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER = 5

const GLFW_GAMEPAD_AXIS_LAST = GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER

const GLFW_NO_ERROR = 0

const GLFW_NOT_INITIALIZED = 0x00010001

const GLFW_NO_CURRENT_CONTEXT = 0x00010002

const GLFW_INVALID_ENUM = 0x00010003

const GLFW_INVALID_VALUE = 0x00010004

const GLFW_OUT_OF_MEMORY = 0x00010005

const GLFW_API_UNAVAILABLE = 0x00010006

const GLFW_VERSION_UNAVAILABLE = 0x00010007

const GLFW_PLATFORM_ERROR = 0x00010008

const GLFW_FORMAT_UNAVAILABLE = 0x00010009

const GLFW_NO_WINDOW_CONTEXT = 0x0001000a

const GLFW_FOCUSED = 0x00020001

const GLFW_ICONIFIED = 0x00020002

const GLFW_RESIZABLE = 0x00020003

const GLFW_VISIBLE = 0x00020004

const GLFW_DECORATED = 0x00020005

const GLFW_AUTO_ICONIFY = 0x00020006

const GLFW_FLOATING = 0x00020007

const GLFW_MAXIMIZED = 0x00020008

const GLFW_CENTER_CURSOR = 0x00020009

const GLFW_TRANSPARENT_FRAMEBUFFER = 0x0002000a

const GLFW_HOVERED = 0x0002000b

const GLFW_FOCUS_ON_SHOW = 0x0002000c

const GLFW_RED_BITS = 0x00021001

const GLFW_GREEN_BITS = 0x00021002

const GLFW_BLUE_BITS = 0x00021003

const GLFW_ALPHA_BITS = 0x00021004

const GLFW_DEPTH_BITS = 0x00021005

const GLFW_STENCIL_BITS = 0x00021006

const GLFW_ACCUM_RED_BITS = 0x00021007

const GLFW_ACCUM_GREEN_BITS = 0x00021008

const GLFW_ACCUM_BLUE_BITS = 0x00021009

const GLFW_ACCUM_ALPHA_BITS = 0x0002100a

const GLFW_AUX_BUFFERS = 0x0002100b

const GLFW_STEREO = 0x0002100c

const GLFW_SAMPLES = 0x0002100d

const GLFW_SRGB_CAPABLE = 0x0002100e

const GLFW_REFRESH_RATE = 0x0002100f

const GLFW_DOUBLEBUFFER = 0x00021010

const GLFW_CLIENT_API = 0x00022001

const GLFW_CONTEXT_VERSION_MAJOR = 0x00022002

const GLFW_CONTEXT_VERSION_MINOR = 0x00022003

const GLFW_CONTEXT_REVISION = 0x00022004

const GLFW_CONTEXT_ROBUSTNESS = 0x00022005

const GLFW_OPENGL_FORWARD_COMPAT = 0x00022006

const GLFW_OPENGL_DEBUG_CONTEXT = 0x00022007

const GLFW_OPENGL_PROFILE = 0x00022008

const GLFW_CONTEXT_RELEASE_BEHAVIOR = 0x00022009

const GLFW_CONTEXT_NO_ERROR = 0x0002200a

const GLFW_CONTEXT_CREATION_API = 0x0002200b

const GLFW_SCALE_TO_MONITOR = 0x0002200c

const GLFW_COCOA_RETINA_FRAMEBUFFER = 0x00023001

const GLFW_COCOA_FRAME_NAME = 0x00023002

const GLFW_COCOA_GRAPHICS_SWITCHING = 0x00023003

const GLFW_X11_CLASS_NAME = 0x00024001

const GLFW_X11_INSTANCE_NAME = 0x00024002

const GLFW_NO_API = 0

const GLFW_OPENGL_API = 0x00030001

const GLFW_OPENGL_ES_API = 0x00030002

const GLFW_NO_ROBUSTNESS = 0

const GLFW_NO_RESET_NOTIFICATION = 0x00031001

const GLFW_LOSE_CONTEXT_ON_RESET = 0x00031002

const GLFW_OPENGL_ANY_PROFILE = 0

const GLFW_OPENGL_CORE_PROFILE = 0x00032001

const GLFW_OPENGL_COMPAT_PROFILE = 0x00032002

const GLFW_CURSOR = 0x00033001

const GLFW_STICKY_KEYS = 0x00033002

const GLFW_STICKY_MOUSE_BUTTONS = 0x00033003

const GLFW_LOCK_KEY_MODS = 0x00033004

const GLFW_RAW_MOUSE_MOTION = 0x00033005

const GLFW_CURSOR_NORMAL = 0x00034001

const GLFW_CURSOR_HIDDEN = 0x00034002

const GLFW_CURSOR_DISABLED = 0x00034003

const GLFW_ANY_RELEASE_BEHAVIOR = 0

const GLFW_RELEASE_BEHAVIOR_FLUSH = 0x00035001

const GLFW_RELEASE_BEHAVIOR_NONE = 0x00035002

const GLFW_NATIVE_CONTEXT_API = 0x00036001

const GLFW_EGL_CONTEXT_API = 0x00036002

const GLFW_OSMESA_CONTEXT_API = 0x00036003

const GLFW_ARROW_CURSOR = 0x00036001

const GLFW_IBEAM_CURSOR = 0x00036002

const GLFW_CROSSHAIR_CURSOR = 0x00036003

const GLFW_HAND_CURSOR = 0x00036004

const GLFW_HRESIZE_CURSOR = 0x00036005

const GLFW_VRESIZE_CURSOR = 0x00036006

const GLFW_CONNECTED = 0x00040001

const GLFW_DISCONNECTED = 0x00040002

const GLFW_JOYSTICK_HAT_BUTTONS = 0x00050001

const GLFW_COCOA_CHDIR_RESOURCES = 0x00051001

const GLFW_COCOA_MENUBAR = 0x00051002

const GLFW_DONT_CARE = -1

# exports
const PREFIXES = ["glfw", "GLFW"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
