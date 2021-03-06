using KrylovMethods
using Base.Test
using LinearOperators
include("getDivGrad.jl")

println("=== Testing CG ===")
# small full system
A = [4.0 1; 1 4]
rhs = [2.0;2]
x,flag,relres,iter,resvec = cg(A,rhs,tol=1e-15,out=2)
@test norm(A*x-rhs)/norm(rhs) <= 1e-15

# CG: test sparse Laplacian
A = getDivGrad(32,32,32)
Alinop = LinearOperator(A)
L = tril(A)
D = diag(A)
U = triu(A)
n = size(A,1)
JAC = LinearOperator(n,n,Float64,false,false,x -> D.\x,nothing, x -> D.\x)
SGS = LinearOperator(n,n,Float64,false,false,x -> L\(D.*(U\x)),nothing, x -> L\(D.*(U\x)))


rhs = randn(size(A,1))
tolCG = 1e-5
# tests with A being matrix
xCG,flagCG,relresCG,iterCG,resvecCG       = cg(A,rhs,tol=tolCG,maxIter=100)
xJAC,flagJAC,relresJAC,iterJAC,resvecJAC  = cg(A,rhs,tol=tolCG,maxIter=100,M=JAC,out=1)
xSGS,flagSGS,relresSGS,iterSGS,resvecSGS  = cg(A,rhs,tol=tolCG,maxIter=100,M=SGS)
# tests with A being function
xCGmf,flagCG,relresCG,iterCG,resvecCG       = cg(Alinop,rhs,tol=tolCG,maxIter=100)
xJACmf,flagJAC,relresJAC,iterJAC,resvecJAC  = cg(Alinop,rhs,tol=tolCG,maxIter=100,M=JAC)
xSGSmf,flagSGS,relresSGS,iterSGS,resvecSGS  = cg(Alinop,rhs,tol=tolCG,maxIter=100,M=SGS)
# tests with random starting guess
xCGr,flagCGr,relresCGr,iterCGr,resvecCGr       = cg(Alinop,rhs,tol=tolCG,maxIter=100,x=randn(size(rhs)))
xJACr,flagJACr,relresJACr,iterJACr,resvecJACr  = cg(Alinop,rhs,tol=tolCG,maxIter=100,M=JAC,x=randn(size(rhs)))
xSGSr,flagSGSr,relresSGSr,iterSGSr,resvecSGSr  = cg(A,rhs,tol=tolCG,maxIter=100,x=randn(size(rhs)))

# test relative residuals
@test norm(A*xCG-rhs)/norm(rhs) <= tolCG
@test norm(A*xSGS-rhs)/norm(rhs) <= tolCG
@test norm(A*xJAC-rhs)/norm(rhs) <= tolCG
@test norm(A*xCGmf-rhs)/norm(rhs) <= tolCG
@test norm(A*xSGSmf-rhs)/norm(rhs) <= tolCG
@test norm(A*xJACmf-rhs)/norm(rhs) <= tolCG
@test norm(A*xCGr-rhs)/norm(rhs) <= tolCG
@test norm(A*xSGSr-rhs)/norm(rhs) <= tolCG
@test norm(A*xJACr-rhs)/norm(rhs) <= tolCG
# preconditioners should at least not increase number of iter
@test iterJAC==iterCG
@test iterSGS<=iterJAC

println("=== CG : All tests passed. ====")
