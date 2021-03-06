# We have rotations along one, two or three axes (e.g. RotX, RotXY and RotXYZ).
# They compose together nicely, so the user can make Euler angles by:
#
#     RotX(θx) * RotY(θy) * RotZ(θz) -> RotXYZ(θx, θy, θz)
#
# and never get confused by the order of application, etc.

#########################
# Single axis rotations #
#########################
"""
    immutable RotX{T} <: Rotation{3,T}
    RotX(theta)

A 3×3 rotation matrix which represents a rotation by `theta` about the X axis.
"""
immutable RotX{T} <: Rotation{3,T}
    theta::T
end

@inline convert{R<:RotX}(::Type{R}, r::RotX) = R(r.theta)


# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline (::Type{R}){R<:RotX}(t::NTuple{9}) = error("Cannot construct a cardinal axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotX{T}, i::Integer)
    T2 = Base.promote_op(sin, T)
    if i == 1
        one(T2)
    elseif i < 5
        zero(T2)
    elseif i == 5
        cos(r.theta)
    elseif i == 6
        sin(r.theta)
    elseif i == 7
        zero(T2)
    elseif i == 8
        -sin(r.theta)
    elseif i == 9
        cos(r.theta)
    else
        throw(BoundsError(r,i))
    end
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotX{T})
    T2 = Base.promote_op(sin, T)
    (one(T2),   zero(T2),     zero(T2),   # transposed representation
     zero(T2),  cos(r.theta), sin(r.theta),
     zero(T2), -sin(r.theta), cos(r.theta))
end

@inline function Base.:*(r::RotX, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    ct, st = cos(r.theta), sin(r.theta)
    T = Base.promote_op(*, typeof(st), eltype(v))
    return similar_type(v,T)(v[1],
                             v[2] * ct - v[3] * st,
                             v[3] * ct + v[2] * st)
end

@inline Base.:*(r1::RotX, r2::RotX) = RotX(r1.theta + r2.theta)

@inline inv(r::RotX) = RotX(-r.theta)

# define null rotations for convenience
@inline eye(::Type{RotX}) = RotX(0.0)
@inline eye{T}(::Type{RotX{T}}) = RotX{T}(zero(T))


"""
    immutable RotY{T} <: Rotation{3,T}
    RotY(theta)

A 3×3 rotation matrix which represents a rotation by `theta` about the Y axis.
"""
immutable RotY{T} <: Rotation{3,T}
    theta::T
end

@inline convert{R<:RotY}(::Type{R}, r::RotY) = R(r.theta)

@inline (::Type{R}){R<:RotY}(t::NTuple{9}) = error("Cannot construct a cardinal axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotY{T}, i::Integer)
    T2 = Base.promote_op(sin, T)
    if i == 1
        cos(r.theta)
    elseif i == 2
        zero(T2)
    elseif i == 3
        -sin(r.theta)
    elseif i == 4
        zero(T2)
    elseif i == 5
        one(T2)
    elseif i == 6
        zero(T2)
    elseif i == 7
        sin(r.theta)
    elseif i == 8
        zero(T2)
    elseif i == 9
        cos(r.theta)
    else
        throw(BoundsError(r,i))
    end
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotY{T})
    T2 = Base.promote_op(sin, T)
    (cos(r.theta), zero(T2), -sin(r.theta),   # transposed representation
     zero(T2),     one(T2),   zero(T2),
     sin(r.theta), zero(T2),  cos(r.theta))
end

@inline function Base.:*(r::RotY, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    ct, st = cos(r.theta), sin(r.theta)
    T = Base.promote_op(*, typeof(st), eltype(v))
    return similar_type(v,T)(v[1] * ct + v[3] * st,
                             v[2],
                             v[3] * ct - v[1] * st)
end

@inline Base.:*(r1::RotY, r2::RotY) = RotY(r1.theta + r2.theta)

@inline inv(r::RotY) = RotY(-r.theta)

# define null rotations for convenience
@inline eye(::Type{RotY}) = RotY(0.0)
@inline eye{T}(::Type{RotY{T}}) = RotY{T}(zero(T))


"""
    immutable RotZ{T} <: Rotation{3,T}
    RotZ(theta)


A 3×3 rotation matrix which represents a rotation by `theta` about the Z axis.
"""
immutable RotZ{T} <: Rotation{3,T}
    theta::T
end

@inline convert{R<:RotZ}(::Type{R}, r::RotZ) = R(r.theta)

@inline (::Type{R}){R<:RotZ}(t::NTuple{9}) = error("Cannot construct a cardinal axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotZ{T}, i::Integer)
    T2 = Base.promote_op(sin, T)
    if i == 1
        cos(r.theta)
    elseif i == 2
        sin(r.theta)
    elseif i == 3
        zero(T2)
    elseif i == 4
        -sin(r.theta)
    elseif i == 5
        cos(r.theta)
    elseif i < 9
        zero(T2)
    elseif i == 9
        one(T2)
    else
        throw(BoundsError(r,i))
    end
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotZ{T})
    T2 = Base.promote_op(sin, T)
    ( cos(r.theta), sin(r.theta), zero(T2),   # transposed representation
     -sin(r.theta), cos(r.theta), zero(T2),
      zero(T2),     zero(T2),     one(T2))
end

@inline function Base.:*(r::RotZ, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    ct, st = cos(r.theta), sin(r.theta)
    T = Base.promote_op(*, typeof(st), eltype(v))
    return similar_type(v,T)(v[1] * ct - v[2] * st,
                             v[2] * ct + v[1] * st,
                             v[3])
end

@inline Base.:*(r1::RotZ, r2::RotZ) = RotZ(r1.theta + r2.theta)

# define null rotations for convenience
@inline eye(::Type{RotZ}) = RotZ(0.0)
@inline eye{T}(::Type{RotZ{T}}) = RotZ{T}(zero(T))

@inline inv(r::RotZ) = RotZ(-r.theta)

function Base.rand{R <: Union{RotX,RotY,RotZ}}(::Type{R})
    T = eltype(R)
    if T == Any
        T = Float64
    end

    return R(2*pi*rand(T))
end


################################################################################
################################################################################

######################
# Two axis rotations #
######################

"""
    immutable RotXY{T} <: Rotation{3,T}
    RotXY(theta_x, theta_y)

A 3×3 rotation matrix which represents a rotation by `theta_y` about the Y axis,
followed by a rotation by `theta_x` about the X axis.
"""
immutable RotXY{T} <: Rotation{3,T}
    theta1::T
    theta2::T
end

@inline (::Type{R}){R<:RotXY}(r::RotXY) = R(r.theta1, r.theta2)
@inline convert{R<:RotXY}(::Type{R}, r::RotXY) = R(r.theta1, r.theta2)

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 2 inputs (not 9).
@inline (::Type{RotXY}){X,Y}(x::X, y::Y) = RotXY{promote_type(X, Y)}(x, y)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline (::Type{R}){R<:RotXY}(t::NTuple{9}) = error("Cannot construct a two-axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotXY{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotXY{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T2 = typeof(sinθ₁)

    # transposed representation
    (cosθ₂,  sinθ₁*sinθ₂,  cosθ₁*-sinθ₂,
     zero(T2),      cosθ₁,          sinθ₁,
     sinθ₂,  -sinθ₁*cosθ₂,   cosθ₁*cosθ₂)
end

@inline function Base.:*(r::RotXY, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(cosθ₂*v[1] + sinθ₂*v[3],
                             sinθ₁*sinθ₂*v[1] + cosθ₁*v[2] + -sinθ₁*cosθ₂*v[3],
                             cosθ₁*-sinθ₂*v[1] + sinθ₁*v[2] + cosθ₁*cosθ₂*v[3])
end

@inline Base.:*(r1::RotX, r2::RotY) = RotXY(r1.theta, r2.theta)
@inline Base.:*(r1::RotXY, r2::RotY) = RotXY(r1.theta1, r1.theta2 + r2.theta)
@inline Base.:*(r1::RotX, r2::RotXY) = RotXY(r1.theta + r2.theta1, r2.theta2)

@inline inv(r::RotXY) = RotYX(-r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotXY}) = RotXY(0.0, 0.0)
@inline eye{T}(::Type{RotXY{T}}) = RotXY{T}(zero(T), zero(T))


"""
    immutable RotYX{T} <: Rotation{3,T}
    RotYX(theta_y, theta_x)

A 3×3 rotation matrix which represents a rotation by `theta_x` about the X axis,
followed by a rotation by `theta_y` about the Y axis.
"""
immutable RotYX{T} <: Rotation{3,T}
    theta1::T
    theta2::T
end

@inline (::Type{R}){R<:RotYX}(r::RotYX) = R(r.theta1, r.theta2)
@inline convert{R<:RotYX}(::Type{R}, r::RotYX) = R(r.theta1, r.theta2)

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 2 inputs (not 9).
@inline (::Type{RotYX}){Y,X}(y::Y, x::X) = RotYX{promote_type(Y, X)}(y, x)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline (::Type{R}){R<:RotYX}(t::NTuple{9}) = error("Cannot construct a two-axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotYX{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotYX{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T2 = typeof(sinθ₁)

    # transposed representation
    (cosθ₁,        zero(T2),       -sinθ₁,
     sinθ₁*sinθ₂,  cosθ₂,   cosθ₁*sinθ₂,
     sinθ₁*cosθ₂,  -sinθ₂,  cosθ₁*cosθ₂)
end

@inline function Base.:*(r::RotYX, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(cosθ₁*v[1] + sinθ₁*sinθ₂*v[2] + sinθ₁*cosθ₂*v[3],
                             cosθ₂*v[2] + -sinθ₂*v[3],
                             -sinθ₁*v[1] + cosθ₁*sinθ₂*v[2] + cosθ₁*cosθ₂*v[3])
end

@inline Base.:*(r1::RotY, r2::RotX) = RotYX(r1.theta, r2.theta)
@inline Base.:*(r1::RotYX, r2::RotX) = RotYX(r1.theta1, r1.theta2 + r2.theta)
@inline Base.:*(r1::RotY, r2::RotYX) = RotYX(r1.theta + r2.theta1, r2.theta2)

@inline inv(r::RotYX) = RotXY(-r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotYX}) = RotYX(0.0, 0.0)
@inline eye{T}(::Type{RotYX{T}}) = RotYX{T}(zero(T), zero(T))


"""
    immutable RotXZ{T} <: Rotation{3,T}
    RotXZ(theta_x, theta_z)

A 3×3 rotation matrix which represents a rotation by `theta_z` about the Z axis,
followed by a rotation by `theta_x` about the X axis.
"""
immutable RotXZ{T} <: Rotation{3,T}
    theta1::T
    theta2::T
end

@inline (::Type{R}){R<:RotXZ}(r::RotXZ) = R(r.theta1, r.theta2)
@inline convert{R<:RotXZ}(::Type{R}, r::RotXZ) = R(r.theta1, r.theta2)

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 2 inputs (not 9).
@inline (::Type{RotXZ}){X,Z}(x::X, z::Z) = RotXZ{promote_type(X, Z)}(x, z)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline (::Type{R}){R<:RotXZ}(t::NTuple{9}) = error("Cannot construct a two-axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotXZ{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotXZ{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T2 = typeof(sinθ₁)

    # transposed representation
    (cosθ₂,   cosθ₁*sinθ₂,  sinθ₁*sinθ₂,
     -sinθ₂,  cosθ₁*cosθ₂,  sinθ₁*cosθ₂,
     zero(T2),       -sinθ₁,       cosθ₁)
end

@inline function Base.:*(r::RotXZ, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(cosθ₂*v[1] + -sinθ₂*v[2],
                             cosθ₁*sinθ₂*v[1] + cosθ₁*cosθ₂*v[2] + -sinθ₁*v[3],
                             sinθ₁*sinθ₂*v[1] + sinθ₁*cosθ₂*v[2] + cosθ₁*v[3])
end

@inline Base.:*(r1::RotX, r2::RotZ) = RotXZ(r1.theta, r2.theta)
@inline Base.:*(r1::RotXZ, r2::RotZ) = RotXZ(r1.theta1, r1.theta2 + r2.theta)
@inline Base.:*(r1::RotX, r2::RotXZ) = RotXZ(r1.theta + r2.theta1, r2.theta2)

@inline inv(r::RotXZ) = RotZX(-r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotXZ}) = RotXZ(0.0, 0.0)
@inline eye{T}(::Type{RotXZ{T}}) = RotXZ{T}(zero(T), zero(T))


"""
    immutable RotZX{T} <: Rotation{3,T}
    RotZX(theta_z, theta_x)

A 3×3 rotation matrix which represents a rotation by `theta_x` about the X axis,
followed by a rotation by `theta_z` about the Z axis.
"""
immutable RotZX{T} <: Rotation{3,T}
    theta1::T
    theta2::T
end

@inline (::Type{R}){R<:RotZX}(r::RotZX) = R(r.theta1, r.theta2)
@inline convert{R<:RotZX}(::Type{R}, r::RotZX) = R(r.theta1, r.theta2)

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 2 inputs (not 9).
@inline (::Type{RotZX}){Z,X}(z::Z, x::X) = RotZX{promote_type(Z, X)}(z, x)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline (::Type{R}){R<:RotZX}(t::NTuple{9}) = error("Cannot construct a two-axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotZX{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotZX{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T2 = typeof(sinθ₁)

    # transposed representation
    ( cosθ₁,         sinθ₁,         zero(T2),
     -sinθ₁*cosθ₂,   cosθ₁*cosθ₂,   sinθ₂,
      sinθ₁*sinθ₂,   cosθ₁*-sinθ₂,  cosθ₂)
end

@inline function Base.:*(r::RotZX, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(cosθ₁*v[1] + -sinθ₁*cosθ₂*v[2] + sinθ₁*sinθ₂*v[3],
                             sinθ₁*v[1] + cosθ₁*cosθ₂*v[2] + cosθ₁*-sinθ₂*v[3],
                             sinθ₂*v[2] + cosθ₂*v[3])
end

@inline Base.:*(r1::RotZ, r2::RotX) = RotZX(r1.theta, r2.theta)
@inline Base.:*(r1::RotZX, r2::RotX) = RotZX(r1.theta1, r1.theta2 + r2.theta)
@inline Base.:*(r1::RotZ, r2::RotZX) = RotZX(r1.theta + r2.theta1, r2.theta2)

@inline inv(r::RotZX) = RotXZ(-r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotZX}) = RotZX(0.0, 0.0)
@inline eye{T}(::Type{RotZX{T}}) = RotZX{T}(zero(T), zero(T))


"""
    immutable RotZY{T} <: Rotation{3,T}
    RotZY(theta_z, theta_y)

A 3×3 rotation matrix which represents a rotation by `theta_y` about the Y axis,
followed by a rotation by `theta_z` about the Z axis.
"""
immutable RotZY{T} <: Rotation{3,T}
    theta1::T
    theta2::T
end

@inline (::Type{R}){R<:RotZY}(r::RotZY) = R(r.theta1, r.theta2)
@inline convert{R<:RotZY}(::Type{R}, r::RotZY) = R(r.theta1, r.theta2)

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 2 inputs (not 9).
@inline (::Type{RotZY}){Z,Y}(z::Z, y::Y) = RotZY{promote_type(Z, Y)}(z, y)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline (::Type{R}){R<:RotZY}(t::NTuple{9}) = error("Cannot construct a two-axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotZY{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotZY{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T2 = typeof(sinθ₁)

    # transposed representation
    ( cosθ₁*cosθ₂,  sinθ₁*cosθ₂, -sinθ₂,
     -sinθ₁,        cosθ₁,        zero(T2),
      cosθ₁*sinθ₂,  sinθ₁*sinθ₂,  cosθ₂)
end

@inline function Base.:*(r::RotZY, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(cosθ₁*cosθ₂*v[1] + -sinθ₁*v[2] + cosθ₁*sinθ₂*v[3],
                             sinθ₁*cosθ₂*v[1] + cosθ₁*v[2] + sinθ₁*sinθ₂*v[3],
                             -sinθ₂*v[1] + cosθ₂*v[3])
end


@inline Base.:*(r1::RotZ, r2::RotY) = RotZY(r1.theta, r2.theta)
@inline Base.:*(r1::RotZY, r2::RotY) = RotZY(r1.theta1, r1.theta2 + r2.theta)
@inline Base.:*(r1::RotZ, r2::RotZY) = RotZY(r1.theta + r2.theta1, r2.theta2)

@inline inv(r::RotZY) = RotYZ(-r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotZY}) = RotZY(0.0, 0.0)
@inline eye{T}(::Type{RotZY{T}}) = RotZY{T}(zero(T), zero(T))


"""
    immutable RotYZ{T} <: Rotation{3,T}
    RotYZ(theta_y, theta_z)

A 3×3 rotation matrix which represents a rotation by `theta_z` about the Z axis,
followed by a rotation by `theta_y` about the Y axis.
"""
immutable RotYZ{T} <: Rotation{3,T}
    theta1::T
    theta2::T
end

@inline (::Type{R}){R<:RotYZ}(r::RotYZ) = R(r.theta1, r.theta2)
@inline convert{R<:RotYZ}(::Type{R}, r::RotYZ) = R(r.theta1, r.theta2)

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 2 inputs (not 9).
@inline (::Type{RotYZ}){Y,Z}(y::Y, z::Z) = RotYZ{promote_type(Y, Z)}(y, z)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline (::Type{R}){R<:RotYZ}(t::NTuple{9}) = error("Cannot construct a two-axis rotation from a matrix")
@inline function Base.getindex{T}(r::RotYZ{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotYZ{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T2 = typeof(sinθ₁)

    # transposed representation
    (cosθ₁*cosθ₂,   sinθ₂,    -sinθ₁*cosθ₂,
     cosθ₁*-sinθ₂,  cosθ₂,     sinθ₁*sinθ₂,
     sinθ₁,         zero(T2),      cosθ₁)
end

@inline function Base.:*(r::RotYZ, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(cosθ₁*cosθ₂*v[1] + cosθ₁*-sinθ₂*v[2] + sinθ₁*v[3],
                             sinθ₂*v[1] + cosθ₂*v[2],
                             -sinθ₁*cosθ₂*v[1] + sinθ₁*sinθ₂*v[2] + cosθ₁*v[3])
end

@inline Base.:*(r1::RotY, r2::RotZ) = RotYZ(r1.theta, r2.theta)
@inline Base.:*(r1::RotYZ, r2::RotZ) = RotYZ(r1.theta1, r1.theta2 + r2.theta)
@inline Base.:*(r1::RotY, r2::RotYZ) = RotYZ(r1.theta + r2.theta1, r2.theta2)

# define null rotations for convenience
@inline eye(::Type{RotYZ}) = RotYZ(0.0, 0.0)
@inline eye{T}(::Type{RotYZ{T}}) = RotYZ{T}(zero(T), zero(T))

@inline inv(r::RotYZ) = RotZY(-r.theta2, -r.theta1)

function Base.rand{R <: Union{RotXY,RotYZ,RotZX, RotXZ, RotYX, RotZY}}(::Type{R})
    T = eltype(R)
    if T == Any
        T = Float64
    end

    # Not really sure what this distribution is, but it's also not clear what
    # it should be! rand(RotXY) *is* invariant to pre-rotations by a RotX and
    # post-rotations by a RotY...
    return R(2*pi*rand(T), 2*pi*rand(T))
end


################################################################################
################################################################################

##########################
# Proper Euler Rotations #
##########################

"""
    immutable RotXYX{T} <: Rotation{3,T}
    RotXYX(theta1, theta2, theta3)

A 3×3 rotation matrix parameterized by the "proper" XYX Euler angle convention,
consisting of first a rotation about the X axis by `theta3`, followed by a
rotation about the Y axis by `theta2`, and finally a rotation about the X axis
by `theta1`.
"""
immutable RotXYX{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotXYX}){X,Y,Z}(x::X, y::Y, z::Z) = RotXYX{promote_type(promote_type(X, Y), Z)}(x, y, z)


# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotXYX}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[2, 1], (-R[3, 1] + eps(t[1])) - eps(t[1]))  # TODO: handle denormal numbers better, as atan2(0,0) != atan2(0,-0)
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2((R[1, 2] * R[1, 2] + R[1, 3] * R[1, 3])^(1/2), R[1, 1]),
        atan2(- R[2, 3]*ct1 - R[3, 3]*st1, R[2, 2]*ct1 + R[3, 2]*st1))
end
@inline function Base.getindex{T}(r::RotXYX{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotXYX{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₂,        sinθ₁*sinθ₂,                        cosθ₁*-sinθ₂,
     sinθ₂*sinθ₃,  cosθ₁*cosθ₃ + -sinθ₁*cosθ₂*sinθ₃,   sinθ₁*cosθ₃ + cosθ₁*cosθ₂*sinθ₃,
     sinθ₂*cosθ₃,  cosθ₁*-sinθ₃ + -sinθ₁*cosθ₂*cosθ₃,  sinθ₁*-sinθ₃ + cosθ₁*cosθ₂*cosθ₃)
end

@inline function Base.:*(r::RotXYX, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        cosθ₂*v[1] + sinθ₂*sinθ₃*v[2] + sinθ₂*cosθ₃*v[3],
        sinθ₁*sinθ₂*v[1] + (cosθ₁*cosθ₃ + -sinθ₁*cosθ₂*sinθ₃)*v[2] + (cosθ₁*-sinθ₃ + -sinθ₁*cosθ₂*cosθ₃)*v[3],
        cosθ₁*-sinθ₂*v[1] + (sinθ₁*cosθ₃ + cosθ₁*cosθ₂*sinθ₃)*v[2] + (sinθ₁*-sinθ₃ + cosθ₁*cosθ₂*cosθ₃)*v[3])
end

@inline Base.:*(r1::RotX, r2::RotYX) = RotXYX(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotXY, r2::RotX) = RotXYX(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotXYX, r2::RotX) = RotXYX(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotX, r2::RotXYX) = RotXYX(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotXYX) = RotXYX(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotXYX}) = RotXYX(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotXYX{T}}) = RotXYX{T}(zero(T), zero(T), zero(T))

"""
    immutable RotXZX{T} <: Rotation{3,T}
    RotXZX(theta1, theta2, theta3)

A 3×3 rotation matrix parameterized by the "proper" XZX Euler angle convention,
consisting of first a rotation about the X axis by `theta3`, followed by a
rotation about the Z axis by `theta2`, and finally a rotation about the X axis
by `theta1`.
"""
immutable RotXZX{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotXZX}){X,Y,Z}(x::X, y::Y, z::Z) = RotXZX{promote_type(promote_type(X, Y), Z)}(x, y, z)


# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotXZX}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[3, 1], R[2, 1])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2((R[1, 2] * R[1, 2] + R[1, 3] * R[1, 3])^(1/2), R[1, 1]),
        atan2(R[3, 2]*ct1 - R[2, 2]*st1, R[3, 3]*ct1 - R[2, 3]*st1))
end
@inline function Base.getindex{T}(r::RotXZX{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotXZX{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₂,         cosθ₁*sinθ₂,                        sinθ₁*sinθ₂,
     -sinθ₂*cosθ₃,  cosθ₁*cosθ₂*cosθ₃ + -sinθ₁*sinθ₃,   sinθ₁*cosθ₂*cosθ₃ + cosθ₁*sinθ₃,
     sinθ₂*sinθ₃,   cosθ₁*cosθ₂*-sinθ₃ + -sinθ₁*cosθ₃,  sinθ₁*cosθ₂*-sinθ₃ + cosθ₁*cosθ₃)
end

@inline function Base.:*(r::RotXZX, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        cosθ₂*v[1] + -sinθ₂*cosθ₃*v[2] + sinθ₂*sinθ₃*v[3],
        cosθ₁*sinθ₂*v[1] + (cosθ₁*cosθ₂*cosθ₃ + -sinθ₁*sinθ₃)*v[2] + (cosθ₁*cosθ₂*-sinθ₃ + -sinθ₁*cosθ₃)*v[3],
        sinθ₁*sinθ₂*v[1] + (sinθ₁*cosθ₂*cosθ₃ + cosθ₁*sinθ₃)*v[2] + (sinθ₁*cosθ₂*-sinθ₃ + cosθ₁*cosθ₃)*v[3])
end

@inline Base.:*(r1::RotX, r2::RotZX) = RotXZX(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotXZ, r2::RotX) = RotXZX(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotXZX, r2::RotX) = RotXZX(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotX, r2::RotXZX) = RotXZX(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotXZX) = RotXZX(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotXZX}) = RotXZX(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotXZX{T}}) = RotXZX{T}(zero(T), zero(T), zero(T))

"""
    immutable RotYXY{T} <: Rotation{3,T}
    RotYXY(theta1, theta2, theta3)

A 3×3 rotation matrix parameterized by the "proper" YXY Euler angle convention,
consisting of first a rotation about the Y axis by `theta3`, followed by a
rotation about the X axis by `theta2`, and finally a rotation about the Y axis
by `theta1`.
"""
immutable RotYXY{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotYXY}){X,Y,Z}(x::X, y::Y, z::Z) = RotYXY{promote_type(promote_type(X, Y), Z)}(x, y, z)


# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotYXY}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[1, 2], R[3, 2])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2((R[2, 1] * R[2, 1] + R[2, 3] * R[2, 3])^(1/2), R[2, 2]),
        atan2(R[1, 3]*ct1 - R[3, 3]*st1, R[1, 1]*ct1 - R[3, 1]*st1))
end
@inline function Base.getindex{T}(r::RotYXY{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotYXY{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₁*cosθ₃ + sinθ₁*cosθ₂*-sinθ₃,  sinθ₂*sinθ₃,   -sinθ₁*cosθ₃ + cosθ₁*cosθ₂*-sinθ₃,
     sinθ₁*sinθ₂,                       cosθ₂,         cosθ₁*sinθ₂,
     cosθ₁*sinθ₃ + sinθ₁*cosθ₂*cosθ₃,   -sinθ₂*cosθ₃,  -sinθ₁*sinθ₃ + cosθ₁*cosθ₂*cosθ₃)
end

@inline function Base.:*(r::RotYXY, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        (cosθ₁*cosθ₃ + sinθ₁*cosθ₂*-sinθ₃)*v[1] + sinθ₁*sinθ₂*v[2] + (cosθ₁*sinθ₃ + sinθ₁*cosθ₂*cosθ₃)*v[3],
        sinθ₂*sinθ₃*v[1] + cosθ₂*v[2] + -sinθ₂*cosθ₃*v[3],
        (-sinθ₁*cosθ₃ + cosθ₁*cosθ₂*-sinθ₃)*v[1] + cosθ₁*sinθ₂*v[2] + (-sinθ₁*sinθ₃ + cosθ₁*cosθ₂*cosθ₃)*v[3])
end

@inline Base.:*(r1::RotY, r2::RotXY) = RotYXY(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotYX, r2::RotY) = RotYXY(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotYXY, r2::RotY) = RotYXY(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotY, r2::RotYXY) = RotYXY(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotYXY) = RotYXY(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotYXY}) = RotYXY(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotYXY{T}}) = RotYXY{T}(zero(T), zero(T), zero(T))


"""
    immutable RotYZY{T} <: Rotation{3,T}
    RotYZY(theta1, theta2, theta3)

A 3×3 rotation matrix parameterized by the "proper" YXY Euler angle convention,
consisting of first a rotation about the Y axis by `theta3`, followed by a
rotation about the Z axis by `theta2`, and finally a rotation about the Y axis
by `theta1`.
"""
immutable RotYZY{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotYZY}){X,Y,Z}(x::X, y::Y, z::Z) = RotYZY{promote_type(promote_type(X, Y), Z)}(x, y, z)


# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotYZY}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[3, 2], -R[1, 2])  # TODO: handle denormal numbers better, as atan2(0,0) != atan2(0,-0)
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2((R[2, 1] * R[2, 1] + R[2, 3] * R[2, 3])^(1/2), R[2, 2]),
        atan2(- R[3, 1]*ct1 - R[1, 1]*st1, R[3, 3]*ct1 + R[1, 3]*st1))
end
@inline function Base.getindex{T}(r::RotYZY{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotYZY{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₁*cosθ₂*cosθ₃ + sinθ₁*-sinθ₃,  sinθ₂*cosθ₃,  -sinθ₁*cosθ₂*cosθ₃ + cosθ₁*-sinθ₃,
     cosθ₁*-sinθ₂,                      cosθ₂,        sinθ₁*sinθ₂,
     cosθ₁*cosθ₂*sinθ₃ + sinθ₁*cosθ₃,   sinθ₂*sinθ₃,  -sinθ₁*cosθ₂*sinθ₃ + cosθ₁*cosθ₃)
end

@inline function Base.:*(r::RotYZY, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        (cosθ₁*cosθ₂*cosθ₃ + sinθ₁*-sinθ₃)*v[1] + cosθ₁*-sinθ₂*v[2] + (cosθ₁*cosθ₂*sinθ₃ + sinθ₁*cosθ₃)*v[3],
        sinθ₂*cosθ₃*v[1] + cosθ₂*v[2] + sinθ₂*sinθ₃*v[3],
        (-sinθ₁*cosθ₂*cosθ₃ + cosθ₁*-sinθ₃)*v[1] + sinθ₁*sinθ₂*v[2] + (-sinθ₁*cosθ₂*sinθ₃ + cosθ₁*cosθ₃)*v[3])
end

@inline Base.:*(r1::RotY, r2::RotZY) = RotYZY(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotYZ, r2::RotY) = RotYZY(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotYZY, r2::RotY) = RotYZY(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotY, r2::RotYZY) = RotYZY(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotYZY) = RotYZY(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotYZY}) = RotYZY(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotYZY{T}}) = RotYZY{T}(zero(T), zero(T), zero(T))


"""
    immutable RotZXZ{T} <: Rotation{3,T}
    RotZXZ(theta1, theta2, theta3)

A 3×3 rotation matrix parameterized by the "proper" ZXZ Euler angle convention,
consisting of first a rotation about the Z axis by `theta3`, followed by a
rotation about the X axis by `theta2`, and finally a rotation about the Z axis
by `theta1`.
"""
immutable RotZXZ{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotZXZ}){X,Y,Z}(x::X, y::Y, z::Z) = RotZXZ{promote_type(promote_type(X, Y), Z)}(x, y, z)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotZXZ}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[1, 3], (-R[2, 3] + eps()) - eps())  # TODO: handle denormal numbers better, as atan2(0,0) != atan2(0,-0)
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2((R[3, 1] * R[3, 1] + R[3, 2] * R[3, 2])^(1/2), R[3, 3]),
        atan2(- R[1, 2]*ct1 - R[2, 2]*st1, R[1, 1]*ct1 + R[2, 1]*st1))
end

@inline function Base.getindex{T}(r::RotZXZ{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotZXZ{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₁*cosθ₃ + -sinθ₁*cosθ₂*sinθ₃,   sinθ₁*cosθ₃ + cosθ₁*cosθ₂*sinθ₃,   sinθ₂*sinθ₃,
     cosθ₁*-sinθ₃ + -sinθ₁*cosθ₂*cosθ₃,  sinθ₁*-sinθ₃ + cosθ₁*cosθ₂*cosθ₃,  sinθ₂*cosθ₃,
     sinθ₁*sinθ₂,                        cosθ₁*-sinθ₂,                      cosθ₂)
end

@inline function Base.:*(r::RotZXZ, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
         (cosθ₁*cosθ₃ + -sinθ₁*cosθ₂*sinθ₃)*v[1] + (cosθ₁*-sinθ₃ + -sinθ₁*cosθ₂*cosθ₃)*v[2] + sinθ₁*sinθ₂*v[3],
         (sinθ₁*cosθ₃ + cosθ₁*cosθ₂*sinθ₃)*v[1] + (sinθ₁*-sinθ₃ + cosθ₁*cosθ₂*cosθ₃)*v[2] + cosθ₁*-sinθ₂*v[3],
         sinθ₂*sinθ₃*v[1] + sinθ₂*cosθ₃*v[2] + cosθ₂*v[3])
end

@inline Base.:*(r1::RotZ, r2::RotXZ) = RotZXZ(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotZX, r2::RotZ) = RotZXZ(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotZXZ, r2::RotZ) = RotZXZ(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotZ, r2::RotZXZ) = RotZXZ(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotZXZ) = RotZXZ(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotZXZ}) = RotZXZ(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotZXZ{T}}) = RotZXZ{T}(zero(T), zero(T), zero(T))


"""
    immutable RotZYZ{T} <: Rotation{3,T}
    RotZYZ(theta1, theta2, theta3)

A 3×3 rotation matrix parameterized by the "proper" ZXZ Euler angle convention,
consisting of first a rotation about the Z axis by `theta3`, followed by a
rotation about the Y axis by `theta2`, and finally a rotation about the Z axis
by `theta1`.
"""
immutable RotZYZ{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotZYZ}){X,Y,Z}(x::X, y::Y, z::Z) = RotZYZ{promote_type(promote_type(X, Y), Z)}(x, y, z)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotZYZ}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[2, 3], R[1, 3])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2((R[3, 1] * R[3, 1] + R[3, 2] * R[3, 2])^(1/2), R[3, 3]),
        atan2(R[2, 1]*ct1 - R[1, 1]*st1, R[2, 2]*ct1 - R[1, 2]*st1))
end

@inline function Base.getindex{T}(r::RotZYZ{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotZYZ{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₁*cosθ₂*cosθ₃ + -sinθ₁*sinθ₃,   sinθ₁*cosθ₂*cosθ₃ + cosθ₁*sinθ₃,   -sinθ₂*cosθ₃,
     cosθ₁*cosθ₂*-sinθ₃ + -sinθ₁*cosθ₃,  sinθ₁*cosθ₂*-sinθ₃ + cosθ₁*cosθ₃,  sinθ₂*sinθ₃,
     cosθ₁*sinθ₂,                        sinθ₁*sinθ₂,                       cosθ₂)
end

@inline function Base.:*(r::RotZYZ, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        (cosθ₁*cosθ₂*cosθ₃ + -sinθ₁*sinθ₃)*v[1] + (cosθ₁*cosθ₂*-sinθ₃ + -sinθ₁*cosθ₃)*v[2] + cosθ₁*sinθ₂*v[3],
        (sinθ₁*cosθ₂*cosθ₃ + cosθ₁*sinθ₃)*v[1] + (sinθ₁*cosθ₂*-sinθ₃ + cosθ₁*cosθ₃)*v[2] + sinθ₁*sinθ₂*v[3],
        -sinθ₂*cosθ₃*v[1] + sinθ₂*sinθ₃*v[2] + cosθ₂*v[3])
end

@inline Base.:*(r1::RotZ, r2::RotYZ) = RotZYZ(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotZY, r2::RotZ) = RotZYZ(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotZYZ, r2::RotZ) = RotZYZ(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotZ, r2::RotZYZ) = RotZYZ(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotZYZ) = RotZYZ(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotZYZ}) = RotZYZ(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotZYZ{T}}) = RotZYZ{T}(zero(T), zero(T), zero(T))


###############################
# Tait-Bryant Euler Rotations #
###############################

"""
    immutable RotXYZ{T} <: Rotation{3,T}
    RotXYZ(theta1, theta2, theta3)
    RotXYZ(roll=r, pitch=p, yaw=y)

A 3×3 rotation matrix parameterized by the "Tait-Bryant" XYZ Euler angle
convention, consisting of first a rotation about the Z axis by `theta3`,
followed by a rotation about the Y axis by `theta2`, and finally a rotation
about the X axis by `theta1`.

The keyword argument form applies roll, pitch and yaw to the X, Y and Z axes
respectively, in XYZ order. (Because it is a right-handed coordinate system,
note that positive pitch is heading in the negative Z axis).
"""
immutable RotXYZ{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotXYZ}){X,Y,Z}(x::X, y::Y, z::Z) = RotXYZ{promote_type(promote_type(X, Y), Z)}(x, y, z)
@inline (::Type{Rot}){Rot<:RotXYZ}(; roll=0, pitch=0, yaw=0) = Rot(roll, pitch, yaw)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotXYZ}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(-R[2, 3], R[3, 3])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2(R[1, 3], (R[1, 1] * R[1, 1] + R[1, 2] * R[1, 2])^(1/2)),
        atan2(R[2, 1]*ct1 + R[3, 1]*st1, R[2, 2]*ct1 + R[3, 2]*st1))
end

@inline function Base.getindex{T}(r::RotXYZ{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotXYZ{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₂*cosθ₃,   sinθ₁*sinθ₂*cosθ₃ + cosθ₁*sinθ₃,   cosθ₁*-sinθ₂*cosθ₃ + sinθ₁*sinθ₃,
     cosθ₂*-sinθ₃,  sinθ₁*sinθ₂*-sinθ₃ + cosθ₁*cosθ₃,  cosθ₁*-sinθ₂*-sinθ₃ + sinθ₁*cosθ₃,
     sinθ₂,         -sinθ₁*cosθ₂,                      cosθ₁*cosθ₂)
end

@inline function Base.:*(r::RotXYZ, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        cosθ₂*cosθ₃*v[1] + cosθ₂*-sinθ₃*v[2] + sinθ₂*v[3],
        (sinθ₁*sinθ₂*cosθ₃ + cosθ₁*sinθ₃)*v[1] + (sinθ₁*sinθ₂*-sinθ₃ + cosθ₁*cosθ₃)*v[2] + -sinθ₁*cosθ₂*v[3],
        (cosθ₁*-sinθ₂*cosθ₃ + sinθ₁*sinθ₃)*v[1] + (cosθ₁*sinθ₂*sinθ₃ + sinθ₁*cosθ₃)*v[2] + cosθ₁*cosθ₂*v[3])
end

@inline Base.:*(r1::RotX, r2::RotYZ) = RotXYZ(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotXY, r2::RotZ) = RotXYZ(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotXYZ, r2::RotZ) = RotXYZ(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotX, r2::RotXYZ) = RotXYZ(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotXYZ) = RotZYX(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotXYZ}) = RotXYZ(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotXYZ{T}}) = RotXYZ{T}(zero(T), zero(T), zero(T))


"""
    immutable RotZYX{T} <: Rotation{3,T}
    RotZYX(theta1, theta2, theta3)
    RotZYX(roll=r, pitch=p, yaw=y)

A 3×3 rotation matrix parameterized by the "Tait-Bryant" ZYX Euler angle
convention, consisting of first a rotation about the X axis by `theta3`,
followed by a rotation about the Y axis by `theta2`, and finally a rotation
about the Z axis by `theta1`.

The keyword argument form applies roll, pitch and yaw to the X, Y and Z axes
respectively, in ZYX order. (Because it is a right-handed coordinate system,
note that positive pitch is heading in the negative Z axis).
"""
immutable RotZYX{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotZYX}){X,Y,Z}(x::X, y::Y, z::Z) = RotZYX{promote_type(promote_type(X, Y), Z)}(x, y, z)
@inline (::Type{Rot}){Rot<:RotZYX}(; roll=0, pitch=0, yaw=0) = Rot(yaw, pitch, roll)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotZYX}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[2, 1], R[1, 1])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2(-R[3, 1], (R[3, 2] * R[3, 2] + R[3, 3] * R[3, 3])^(1/2)),
        atan2(R[1, 3]*st1 - R[2, 3]*ct1, R[2, 2]*ct1 - R[1, 2]*st1))
end

@inline function Base.getindex{T}(r::RotZYX{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotZYX{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    ( cosθ₁*cosθ₂,                       sinθ₁*cosθ₂,                      -sinθ₂,
     -sinθ₁*cosθ₃ + cosθ₁*sinθ₂*sinθ₃,   cosθ₁*cosθ₃ + sinθ₁*sinθ₂*sinθ₃,   cosθ₂*sinθ₃,
      sinθ₁*sinθ₃ + cosθ₁*sinθ₂*cosθ₃,   cosθ₁*-sinθ₃ + sinθ₁*sinθ₂*cosθ₃,  cosθ₂*cosθ₃)
end

@inline function Base.:*(r::RotZYX, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        cosθ₁*cosθ₂*v[1] + (-sinθ₁*cosθ₃ + cosθ₁*sinθ₂*sinθ₃)*v[2] + (sinθ₁*sinθ₃ + cosθ₁*sinθ₂*cosθ₃)*v[3],
        sinθ₁*cosθ₂*v[1] + (cosθ₁*cosθ₃ + sinθ₁*sinθ₂*sinθ₃)*v[2] + (cosθ₁*-sinθ₃ + sinθ₁*sinθ₂*cosθ₃)*v[3],
        -sinθ₂*v[1] + cosθ₂*sinθ₃*v[2] + cosθ₂*cosθ₃*v[3])
end

@inline Base.:*(r1::RotZ, r2::RotYX) = RotZYX(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotZY, r2::RotX) = RotZYX(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotZYX, r2::RotX) = RotZYX(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotZ, r2::RotZYX) = RotZYX(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotZYX) = RotXYZ(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotZYX}) = RotZYX(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotZYX{T}}) = RotZYX{T}(zero(T), zero(T), zero(T))


"""
    immutable RotXZY{T} <: Rotation{3,T}
    RotXZY(theta1, theta2, theta3)
    RotXZY(roll=r, pitch=p, yaw=y)

A 3×3 rotation matrix parameterized by the "Tait-Bryant" XZY Euler angle
convention, consisting of first a rotation about the Y axis by `theta3`,
followed by a rotation about the Z axis by `theta2`, and finally a rotation
about the X axis by `theta1`.

The keyword argument form applies roll, pitch and yaw to the X, Y and Z axes
respectively, in XZY order. (Because it is a right-handed coordinate system,
note that positive pitch is heading in the negative Z axis).
"""
immutable RotXZY{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotXZY}){X,Y,Z}(x::X, y::Y, z::Z) = RotXZY{promote_type(promote_type(X, Y), Z)}(x, y, z)
@inline (::Type{Rot}){Rot<:RotXZY}(; roll=0, pitch=0, yaw=0) = Rot(roll, yaw, pitch)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotXZY}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[3, 2], R[2, 2])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2(-R[1, 2], (R[1, 1] * R[1, 1] + R[1, 3] * R[1, 3])^(1/2)),
        atan2(R[2, 1]*st1 - R[3, 1]*ct1, R[3, 3]*ct1 - R[2, 3]*st1))
end

@inline function Base.getindex{T}(r::RotXZY{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotXZY{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    ( cosθ₂*cosθ₃,  cosθ₁*sinθ₂*cosθ₃ + sinθ₁*sinθ₃,   sinθ₁*sinθ₂*cosθ₃ + cosθ₁*-sinθ₃,
     -sinθ₂,        cosθ₁*cosθ₂,                       sinθ₁*cosθ₂,
      cosθ₂*sinθ₃,  cosθ₁*sinθ₂*sinθ₃ + -sinθ₁*cosθ₃,  sinθ₁*sinθ₂*sinθ₃ + cosθ₁*cosθ₃)
end

@inline function Base.:*(r::RotXZY, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        cosθ₂*cosθ₃*v[1] + -sinθ₂*v[2] + cosθ₂*sinθ₃*v[3],
        (cosθ₁*sinθ₂*cosθ₃ + sinθ₁*sinθ₃)*v[1] + cosθ₁*cosθ₂*v[2] + (cosθ₁*sinθ₂*sinθ₃ + -sinθ₁*cosθ₃)*v[3],
        (sinθ₁*sinθ₂*cosθ₃ + cosθ₁*-sinθ₃)*v[1] + sinθ₁*cosθ₂*v[2] + (sinθ₁*sinθ₂*sinθ₃ + cosθ₁*cosθ₃)*v[3])
end

@inline Base.:*(r1::RotX, r2::RotZY) = RotXZY(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotXZ, r2::RotY) = RotXZY(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotXZY, r2::RotY) = RotXZY(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotX, r2::RotXZY) = RotXZY(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotXZY) = RotYZX(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotXZY}) = RotXZY(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotXZY{T}}) = RotXZY{T}(zero(T), zero(T), zero(T))


"""
    immutable RotYZX{T} <: Rotation{3,T}
    RotYZX(theta1, theta2, theta3)
    RotYZX(roll=r, pitch=p, yaw=y)

A 3×3 rotation matrix parameterized by the "Tait-Bryant" YZX Euler angle
convention, consisting of first a rotation about the X axis by `theta3`,
followed by a rotation about the Z axis by `theta2`, and finally a rotation
about the Y axis by `theta1`.

The keyword argument form applies roll, pitch and yaw to the X, Y and Z axes
respectively, in YZX order. (Because it is a right-handed coordinate system,
note that positive pitch is heading in the negative Z axis).
"""
immutable RotYZX{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotYZX}){X,Y,Z}(x::X, y::Y, z::Z) = RotYZX{promote_type(promote_type(X, Y), Z)}(x, y, z)
@inline (::Type{Rot}){Rot<:RotYZX}(; roll=0, pitch=0, yaw=0) = Rot(pitch, yaw, roll)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotYZX}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(-R[3, 1], R[1, 1])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2(R[2, 1], (R[2, 2] * R[2, 2] + R[2, 3] * R[2, 3])^(1/2)),
        atan2(R[3, 2]*ct1 + R[1, 2]*st1, R[3, 3]*ct1 + R[1, 3]*st1))
end

@inline function Base.getindex{T}(r::RotYZX{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotYZX{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₁*cosθ₂,                        sinθ₂,         -sinθ₁*cosθ₂,
     cosθ₁*-sinθ₂*cosθ₃ + sinθ₁*sinθ₃,   cosθ₂*cosθ₃,   sinθ₁*sinθ₂*cosθ₃ + cosθ₁*sinθ₃,
     cosθ₁*sinθ₂*sinθ₃ + sinθ₁*cosθ₃,    cosθ₂*-sinθ₃,  sinθ₁*sinθ₂*-sinθ₃ + cosθ₁*cosθ₃)
end

@inline function Base.:*(r::RotYZX, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        cosθ₁*cosθ₂*v[1] + (cosθ₁*-sinθ₂*cosθ₃ + sinθ₁*sinθ₃)*v[2] + (cosθ₁*-sinθ₂*-sinθ₃ + sinθ₁*cosθ₃)*v[3],
        sinθ₂*v[1] + cosθ₂*cosθ₃*v[2] + cosθ₂*-sinθ₃*v[3],
        -sinθ₁*cosθ₂*v[1] + (sinθ₁*sinθ₂*cosθ₃ + cosθ₁*sinθ₃)*v[2] + (sinθ₁*sinθ₂*-sinθ₃ + cosθ₁*cosθ₃)*v[3])
end

@inline Base.:*(r1::RotY, r2::RotZX) = RotYZX(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotYZ, r2::RotX) = RotYZX(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotYZX, r2::RotX) = RotYZX(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotY, r2::RotYZX) = RotYZX(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotYZX) = RotXZY(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotYZX}) = RotYZX(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotYZX{T}}) = RotYZX{T}(zero(T), zero(T), zero(T))


"""
    immutable RotYXZ{T} <: Rotation{3,T}
    RotYXZ(theta1, theta2, theta3)
    RotYXZ(roll=r, pitch=p, yaw=y)

A 3×3 rotation matrix parameterized by the "Tait-Bryant" YXZ Euler angle
convention, consisting of first a rotation about the Z axis by `theta3`,
followed by a rotation about the X axis by `theta2`, and finally a rotation
about the Y axis by `theta1`.

The keyword argument form applies roll, pitch and yaw to the X, Y and Z axes
respectively, in YXZ order. (Because it is a right-handed coordinate system,
note that positive pitch is heading in the negative Z axis).
"""
immutable RotYXZ{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotYXZ}){X,Y,Z}(x::X, y::Y, z::Z) = RotYXZ{promote_type(promote_type(X, Y), Z)}(x, y, z)
@inline (::Type{Rot}){Rot<:RotYXZ}(; roll=0, pitch=0, yaw=0) = Rot(pitch, roll, yaw)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotYXZ}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(R[1, 3], R[3, 3])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2(-R[2, 3], (R[2, 1] * R[2, 1] + R[2, 2] * R[2, 2])^(1/2)),
        atan2(R[3, 2]*st1 - R[1, 2]*ct1, R[1, 1]*ct1 - R[3, 1]*st1))
end

@inline function Base.getindex{T}(r::RotYXZ{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotYXZ{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    (cosθ₁*cosθ₃ + sinθ₁*sinθ₂*sinθ₃,   cosθ₂*sinθ₃,  -sinθ₁*cosθ₃ + cosθ₁*sinθ₂*sinθ₃,
     cosθ₁*-sinθ₃ + sinθ₁*sinθ₂*cosθ₃,  cosθ₂*cosθ₃,  sinθ₁*sinθ₃ + cosθ₁*sinθ₂*cosθ₃,
     sinθ₁*cosθ₂,                       -sinθ₂,       cosθ₁*cosθ₂)
end

@inline function Base.:*(r::RotYXZ, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        (cosθ₁*cosθ₃ + sinθ₁*sinθ₂*sinθ₃)*v[1] + (cosθ₁*-sinθ₃ + sinθ₁*sinθ₂*cosθ₃)*v[2] + sinθ₁*cosθ₂*v[3],
        cosθ₂*sinθ₃*v[1] + cosθ₂*cosθ₃*v[2] + -sinθ₂*v[3],
        (-sinθ₁*cosθ₃ + cosθ₁*sinθ₂*sinθ₃)*v[1] + (sinθ₁*sinθ₃ + cosθ₁*sinθ₂*cosθ₃)*v[2] + cosθ₁*cosθ₂*v[3])
end

@inline Base.:*(r1::RotY, r2::RotXZ) = RotYXZ(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotYX, r2::RotZ) = RotYXZ(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotYXZ, r2::RotZ) = RotYXZ(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotY, r2::RotYXZ) = RotYXZ(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotYXZ) = RotZXY(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotYXZ}) = RotYXZ(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotYXZ{T}}) = RotYXZ{T}(zero(T), zero(T), zero(T))


"""
    immutable RotZXY{T} <: Rotation{3,T}
    RotZXY(theta1, theta2, theta3)
    RotZXY(roll=r, pitch=p, yaw=y)

A 3×3 rotation matrix parameterized by the "Tait-Bryant" ZXY Euler angle
convention, consisting of first a rotation about the Y axis by `theta3`,
followed by a rotation about the X axis by `theta2`, and finally a rotation
about the Z axis by `theta1`.

The keyword argument form applies roll, pitch and yaw to the X, Y and Z axes
respectively, in ZXY order. (Because it is a right-handed coordinate system,
note that positive pitch is heading in the negative Z axis).
"""
immutable RotZXY{T} <: Rotation{3,T}
    theta1::T
    theta2::T
    theta3::T
end

# StaticArrays will take over *all* the constructors and put everything in a tuple...
# but this isn't quite what we mean when we have 3 inputs (not 9).
@inline (::Type{RotZXY}){X,Y,Z}(x::X, y::Y, z::Z) = RotZXY{promote_type(promote_type(X, Y), Z)}(x, y, z)
@inline (::Type{Rot}){Rot<:RotZXY}(; roll=0, pitch=0, yaw=0) = Rot(yaw, roll, pitch)

# These 2 functions are enough to satisfy the entire StaticArrays interface:
@inline function (::Type{Rot}){Rot <: RotZXY}(t::NTuple{9})
    R = SMatrix{3,3}(t)

    t1 = atan2(-R[1, 2], R[2, 2])
    ct1, st1 = cos(t1), sin(t1)

    Rot(t1,
        atan2(R[3, 2], (R[3, 1] * R[3, 1] + R[3, 3] * R[3, 3])^(1/2)),
        atan2(R[1, 3]*ct1 + R[2, 3]*st1, R[1, 1]*ct1 + R[2, 1]*st1))
end

@inline function Base.getindex{T}(r::RotZXY{T}, i::Integer)
    Tuple(r)[i] # Slow...
end

@inline function Base.convert{T}(::Type{Tuple}, r::RotZXY{T})
    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    # transposed representation
    ( cosθ₁*cosθ₃ + sinθ₁*sinθ₂*-sinθ₃,  sinθ₁*cosθ₃ + cosθ₁*-sinθ₂*-sinθ₃,  cosθ₂*-sinθ₃,
     -sinθ₁*cosθ₂,                       cosθ₁*cosθ₂,                        sinθ₂,
      cosθ₁*sinθ₃ + sinθ₁*sinθ₂*cosθ₃,   sinθ₁*sinθ₃ + cosθ₁*-sinθ₂*cosθ₃,   cosθ₂*cosθ₃)
end

@inline function Base.:*(r::RotZXY, v::StaticVector)
    if length(v) != 3
        throw("Dimension mismatch: cannot rotate a vector of length $(length(v))")
    end

    sinθ₁ = sin(r.theta1)
    cosθ₁ = cos(r.theta1)
    sinθ₂ = sin(r.theta2)
    cosθ₂ = cos(r.theta2)
    sinθ₃ = sin(r.theta3)
    cosθ₃ = cos(r.theta3)

    T = Base.promote_op(*, typeof(sinθ₁), eltype(v))

    return similar_type(v,T)(
        (cosθ₁*cosθ₃ + sinθ₁*sinθ₂*-sinθ₃)*v[1] + -sinθ₁*cosθ₂*v[2] + (cosθ₁*sinθ₃ + sinθ₁*sinθ₂*cosθ₃)*v[3],
        (sinθ₁*cosθ₃ + cosθ₁*-sinθ₂*-sinθ₃)*v[1] + cosθ₁*cosθ₂*v[2] + (sinθ₁*sinθ₃ + cosθ₁*-sinθ₂*cosθ₃)*v[3],
         cosθ₂*-sinθ₃*v[1] + sinθ₂*v[2] + cosθ₂*cosθ₃*v[3])
end

@inline Base.:*(r1::RotZ, r2::RotXY) = RotZXY(r1.theta, r2.theta1, r2.theta2)
@inline Base.:*(r1::RotZX, r2::RotY) = RotZXY(r1.theta1, r1.theta2, r2.theta)
@inline Base.:*(r1::RotZXY, r2::RotY) = RotZXY(r1.theta1, r1.theta2, r1.theta3 + r2.theta)
@inline Base.:*(r1::RotZ, r2::RotZXY) = RotZXY(r1.theta + r2.theta1, r2.theta2, r2.theta3)

@inline inv(r::RotZXY) = RotYXZ(-r.theta3, -r.theta2, -r.theta1)

# define null rotations for convenience
@inline eye(::Type{RotZXY}) = RotZXY(0.0, 0.0, 0.0)
@inline eye{T}(::Type{RotZXY{T}}) = RotZXY{T}(zero(T), zero(T), zero(T))
