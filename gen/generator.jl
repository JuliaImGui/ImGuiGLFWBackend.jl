using Clang.Generators
using GLFW.GLFW_jll

cd(@__DIR__)

include_dir = joinpath(GLFW_jll.artifact_dir, "include")
glfw_h = joinpath(include_dir, "GLFW", "glfw3.h") |> normpath

options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

ctx = create_context(glfw_h, args, options)

build!(ctx)
