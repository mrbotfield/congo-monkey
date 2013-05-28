
// Native code for display utils.

// See glfw user guide.

static void HideMouseCursor()
{
	glfwDisable( GLFW_MOUSE_CURSOR );
}

static void RestoreMouseCursor()
{
	glfwEnable( GLFW_MOUSE_CURSOR );
}
