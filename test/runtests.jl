using MangalSuppMat
using Test

test_path = @__DIR__
test_files = readdir(test_path)
filter!(f -> startswith(f, "0"), test_files)

global test_n
global anyerrors

test_n = 1
anyerrors = false

for my_test in test_files
    println("\033[1m\033[33m RUNNING\033[0m\t$(lpad(test_n,2))\t$(my_test)")
  try
    include(my_test)
    println("\033[1m\033[32m SUCCESS\n")
  catch e
    global anyerrors = true
    println("\033[1m\033[31m ERROR")
    showerror(stdout, e, backtrace())
    println()
    throw("TEST FAILED")
  end
  global test_n += 1
end

if anyerrors
  throw("Tests failed")
end
