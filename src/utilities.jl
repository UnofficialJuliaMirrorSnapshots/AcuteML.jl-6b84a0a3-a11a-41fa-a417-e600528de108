using EzXML
import EzXML: Document, Node

export findalllocal, findfirstlocal, findfirstcontent, findallcontent, addelementOne!, addelementVect!, updateallcontent!, updatefirstcontent!, docOrElmInit, UN
################################################################
UN{T}= Union{T, Nothing}
################################################################
# Extractors

"""
    findfirstlocal(string, node)

findfirst with ignoring namespaces. It considers element.name for returning the elements
"""
function findfirstlocal(s::String, node::Union{Node, Document})
    out = nothing # return nothing if nothing is found
    for child in eachelement(node)
        if child.name == s
            out = child
            break
        end
    end
    return out
end

"""
    findfirstlocal(string, node)

findalllocal with ignoring namespaces. It considers element.name for returning the elements
"""
function findalllocal(s::String, node::Union{Node, Document})
    out = Node[]
    for child in eachelement(node)
        if child.name == s
            push!(out, child)
        end
    end
    if !isempty(out)
        return out
    else # return nothing if nothing is found
        return nothing
    end
end
################################################################
# Single extraction
"""
    findfirstcontent(element,node, amlType)
    findfirstcontent(type,element,node, amlType)

Returns first element content. It also convert to the desired format by passing type. element is given as string.
```julia
findfirstcontent("/instrument-name",node, 0)
findfirstcontent(UInt8,"/midi-channel",node, 0)
```
"""
function findfirstcontent(::Type{T}, s::String, node::Union{Node, Document}, amlType::Int64) where{T<:String} # for strings

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elm = findfirst(s,node)
        else
            elm = findfirstlocal(s,node)
        end

        if isnothing(elm) # return nothing if nothing is found
            return nothing
        else
            return elm.content
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elm = node[s]
            return elm

        else # return nothing if nothing is found
            elm = nothing
            return elm
        end

    end



end


# if no type is provided consider it to be string
findfirstcontent(s::String,node::Union{Node, Document}, amlType::Int64) = findfirstcontent(Union{String, Nothing}, s, node, amlType)

# for numbers
function findfirstcontent(::Type{T},s::String,node::Union{Node, Document}, amlType::Int64) where {T<:Union{Number,Bool}}

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elm = findfirst(s,node)
        else
            elm = findfirstlocal(s,node)
        end

        if isnothing(elm) # return nothing if nothing is found
            return nothing
        else
            return parse(T, elm.content)
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elm = parse(T, node[s])
            return elm

        else # return nothing if nothing is found
            elm = nothing
            return elm
        end

    end


end

# for defined types
function findfirstcontent(::Type{T},s::String,node::Union{Node, Document}, amlType::Int64) where {T}

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elm = findfirst(s,node)
        else
            elm = findfirstlocal(s,node)
        end

        if isnothing(elm) # return nothing if nothing is found
            return nothing
        else
            return T(elm)
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elm = node[s]
            return elm

        else # return nothing if nothing is found
            elm = nothing
            return elm
        end

    end


end

# Union with Nothing
findfirstcontent(::Type{UN{T}},s::String,node::Union{Node, Document}, amlType::Int64) where {T} = findfirstcontent(T,s,node, amlType)

# Nothing Alone
findfirstcontent(::Type{Nothing},s::String,node::Union{Node, Document}, amlType::Int64) = nothing
################################################################
# Vector extraction
"""
    findallcontent(type, string, node, amlType)

Finds all the elements with the address of string in the node, and converts the elements to Type object.
```julia
findallcontent(UInt8,"/midi-channel",node, 0)
```
"""
function findallcontent(::Type{Vector{T}}, s::String, node::Union{Node, Document}, amlType::Int64) where{T<:String} # for strings


    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elmsNode = findall(s, node) # a vector of Node elements
        else
            elmsNode = findalllocal(s, node) # a vector of Node elements
        end

        if isnothing(elmsNode)  # return nothing if nothing is found
            return nothing
        else
            elmsType = Vector{T}(undef, length(elmsNode)) # a vector of Type elements
            i=1
            for elm in elmsNode
                elmsType[i]=elm.content
                i+=1
            end
            return elmsType
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elmsNode = node[s]
            elmsType = Vector{T}(undef, length(elmsNode)) # a vector of Type elements
            i=1
            for elm in elmsNode
                elmsType[i]=elm
                i+=1
            end
            return elmsType
        else  # return nothing if nothing is found
            elmsNode = nothing
        end
    end
end
# if no type is provided consider it to be string
findallcontent(s::String, node::Union{Node, Document}, amlType::Int64) = findallcontent(Vector{Union{String, Nothing}},s, node, amlType)

# for numbers
function findallcontent(::Type{Vector{T}}, s::String, node::Union{Node, Document}, amlType::Int64) where{T<:Union{Number,Bool}}

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elmsNode = findall(s, node) # a vector of Node elements
        else
            elmsNode = findalllocal(s, node) # a vector of Node elements
        end

        if isnothing(elmsNode) # return nothing if nothing is found
            return nothing
        else
            elmsType = Vector{T}(undef, length(elmsNode)) # a vector of Type elements
            i=1
            for elm in elmsNode
                elmsType[i]=parse(T, elm.content)
                i+=1
            end
            return elmsType
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elmsNode = parse(T, node[s])
            elmsType = Vector{T}(undef, length(elmsNode)) # a vector of Type elements
            i=1
            for elm in elmsNode
                elmsType[i]=parse(T, elm)
                i+=1
            end
            return elmsType
        else  # return nothing if nothing is found
            elmsNode = nothing
        end

    end



end

# for defined types
function findallcontent(::Type{Vector{T}}, s::String, node::Union{Node, Document}, amlType::Int64) where{T}

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elmsNode = findall(s, node) # a vector of Node elements
        else
            elmsNode = findalllocal(s, node) # a vector of Node elements
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elmsNode = node[s]
        else  # return nothing if nothing is found
            elmsNode = nothing
        end
    end


    if isnothing(elmsNode) # return nothing if nothing is found
        return nothing
    else
        elmsType = Vector{T}(undef, length(elmsNode)) # a vector of Type elements
        i=1
        for elm in elmsNode
            elmsType[i]=T(elm)
            i+=1
        end
        return elmsType
    end

end

# Union with Nothing
findallcontent(::Type{Vector{UN{T}}},s::String,node::Union{Node, Document}, amlType::Int64) where {T} = findallcontent(Vecotr{T},s,node, amlType)

# Nothing Alone
findallcontent(::Type{Vector{Nothing}},s::String,node::Union{Node, Document}, amlType::Int64) = nothing
################################################################
# Constructors

################################################################
# Document
#  defined or nothing for Documents # add strings and others for documents
"""
    addelementOne!(node, name, value, amlType)

Add one element to a node/document
```
"""
function addelementOne!(aml::Document, name::String, value, amlType::Int64)

    if !isnothing(value) # do nothing if value is nothing

        if hasroot(aml)
            amlNode = root(aml)
            if hasmethod(string, Tuple{T})
                if amlType == 0 # normal elements

                    addelement!(aml, name, string(value))
                elseif amlType == 2 # Attributes

                    link!(aml, AttributeNode(name, string(value)))

                end
            else
                link!(amlNode,value.aml)
            end
        else
            setroot!(aml, value.aml)
        end

    end

end

# strings
function addelementOne!(aml::Document, name::String, value::String, amlType::Int64)

    if !isnothing(value) # do nothing if value is nothing

        if hasroot(aml)
            amlNode = root(aml)

            if amlType == 0 # normal elements

                addelement!(amlNode, name, value)

            elseif amlType == 2 # Attributes

                link!(amlNode, AttributeNode(name, value))

            end
        else
            error("You cannot insert a string in the document directly. Define a @aml defined field for xd/hd struct")
        end

    end
end

# number
function addelementOne!(aml::Document, name::String, value::T, amlType::Int64) where {T<:Union{Number, Bool}}

    if !isnothing(value) # do nothing if value is nothing

        if hasroot(aml)
            amlNode = root(aml)

            if amlType == 0 # normal elements

                addelement!(amlNode, name, string(value))
            elseif amlType == 2 # Attributes

                link!(amlNode, AttributeNode(name, string(value)))

            end
        else
            error("You cannot insert a number in the document directly. Define a @aml defined field for xd/hd struct")
        end

    end
end
################################################################
# vector of strings
"""
    addelementVect!(node, name, value, amlType)

Add a vector to a node/document
```
"""
function addelementVect!(aml::Document, name::String, value::Vector{String}, amlType::Int64)


    if hasroot(aml)
        amlNode = root(aml)

        if amlType == 0 # normal elements

            for ii = 1:length(value)
                if !isnothing(value[ii]) # do nothing if value is nothing
                    addelement!(amlNode, name, value[ii])
                end
            end

        elseif amlType == 2 # Attributes

            for ii = 1:length(value)
                if !isnothing(value[ii]) # do nothing if value is nothing
                    link!(amlNode, AttributeNode(name, value[ii]))
                end
            end
        end

    else
        error("You cannot insert a vector in the document directly. Define a @aml defined field for xd/hd struct")
    end

end

# vector of numbers
function addelementVect!(aml::Document, name::String, value::Vector{T}, amlType::Int64) where {T<:Union{Number, Bool}}

    if hasroot(aml)
        amlNode = root(aml)

        if amlType == 0 # normal elements

            for ii = 1:length(value)
                if !isnothing(value[ii]) # do nothing if value is nothing
                    addelement!(amlNode, name, string(value[ii]))
                end
            end

        elseif amlType == 2 # Attributes

            for ii = 1:length(value)
                if !isnothing(value[ii]) # do nothing if value is nothing
                    link!(amlNode, AttributeNode(name, string(value[ii])))
                end
            end
        end

    else
        error("You cannot put string in the document directly.Define a @aml defined field for xd/hd struct")
    end

end

#  vector of defined or nothing
function addelementVect!(aml::Document, name::String, value::Vector{T}, amlType::Int64) where {T}
    if hasroot(aml)
        amlNode = root(aml)

        for ii = 1:length(value)
            if !isnothing(value[ii]) # do nothing if value is nothing
                if hasmethod(string, Tuple{T})
                    if amlType == 0 # normal elements

                        addelement!(amlNode, name, string(value[ii]))
                    elseif amlType == 2 # Attributes

                        link!(amlNode, AttributeNode(name, string(value[ii])))

                    end
                else
                    link!(amlNode,value[ii].aml)
                end
            end
        end

    else
        error("You cannot put string in the document directly. Define a @aml defined field for xd/hd struct")
    end

end

################################################################
# Nodes
# strings
function addelementOne!(aml::Node, name::String, value::String, amlType::Int64)

    if !isnothing(value) # do nothing if value is nothing

        if amlType == 0 # normal elements

            addelement!(aml, name, value)

        elseif amlType == 2 # Attributes

            link!(aml, AttributeNode(name, value))

        end
    end
end

# number
function addelementOne!(aml::Node, name::String, value::T, amlType::Int64) where {T<:Union{Number, Bool}}

    if !isnothing(value) # do nothing if value is nothing

        if amlType == 0 # normal elements

            addelement!(aml, name, string(value))
        elseif amlType == 2 # Attributes

            link!(aml, AttributeNode(name, string(value)))

        end
    end
end

#  defined or nothing
function addelementOne!(aml::Node, name::String, value::T, amlType::Int64) where {T}
    if !isnothing(value)
        if hasmethod(string, Tuple{T})
            if amlType == 0 # normal elements

                addelement!(aml, name, string(value))
            elseif amlType == 2 # Attributes

                link!(aml, AttributeNode(name, string(value)))

            end
        else
            link!(aml,value.aml)
        end
    end
end

# vector of strings
function addelementVect!(aml::Node, name::String, value::Vector{String}, amlType::Int64)


    if amlType == 0 # normal elements

        for ii = 1:length(value)
            if !isnothing(value[ii]) # do nothing if value is nothing
                addelement!(aml, name, value[ii])
            end
        end

    elseif amlType == 2 # Attributes

        for ii = 1:length(value)
            if !isnothing(value[ii]) # do nothing if value is nothing
                link!(aml, AttributeNode(name, value[ii]))
            end
        end
    end
end

# vector of numbers
function addelementVect!(aml::Node, name::String, value::Vector{T}, amlType::Int64) where {T<:Union{Number, Bool}}

    if amlType == 0 # normal elements

        for ii = 1:length(value)
            if !isnothing(value[ii]) # do nothing if value is nothing
                addelement!(aml, name, string(value[ii]))
            end
        end

    elseif amlType == 2 # Attributes

        for ii = 1:length(value)
            if !isnothing(value[ii]) # do nothing if value is nothing
                link!(aml, AttributeNode(name, string(value[ii])))
            end
        end
    end
end

#  vector of defined or nothing
function addelementVect!(aml::Node, name::String, value::Vector{T}, amlType::Int64) where {T}
    for ii = 1:length(value)
        if !isnothing(value[ii]) # do nothing if value is nothing
            if hasmethod(string, Tuple{T})
                if amlType == 0 # normal elements

                    addelement!(aml, name, string(value[ii]))
                elseif amlType == 2 # Attributes

                    link!(aml, AttributeNode(name, string(value[ii])))

                end
            else
                link!(aml,value[ii].aml)
            end
        end
    end
end

################################################################
# Updaters
################################################################
# Single Updater
"""
    updatefirstcontent(value, string, node, amlType)

Updates first element content. It also converts any type to string. element is given as string.
"""
function updatefirstcontent!(value::T, s::String, node::Union{Node, Document}, amlType::Int64) where{T<:Union{String, Number, Bool}} # for strings, number and bool

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elm = findfirst(s,node)
        else
            elm = findfirstlocal(s,node)
        end

        if isnothing(elm) # error if nothing is found
            return error("field not found in aml")
        else
            elm.content = value
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            node[s] = value

        else # error if nothing is found
            return error("field not found in aml")
        end

    end



end

# for defined types
function updatefirstcontent!(value::T, s::String,node::Union{Node, Document}, amlType::Int64) where {T}

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elm = findfirst(s,node)
        else
            elm = findfirstlocal(s,node)
        end

        if isnothing(elm) # error if nothing is found
            return error("field not found in aml")
        else
            if hasmethod(string, Tuple{T})
                elm.content = string(value)
            else
                unlink!(elm)
                link!(node, value.aml)
            end
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elm = node[s]
            unlink!(elm)
            link!(node, value.aml)

        else # error if nothing is found
            return error("field not found in aml")
        end

    end


end

# Nothing Alone
function updatefirstcontent!(value::Nothing, s::String,node::Union{Node, Document}, amlType::Int64)

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elm = findfirst(s,node)
        else
            elm = findfirstlocal(s,node)
        end

        if isnothing(elm) # error if nothing is found
            return error("field not found in aml")
        else
            unlink!(elm)
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elm = node[s]
            unlink!(elm)

        else # error if nothing is found
            return error("field not found in aml")
        end

    end


end
################################################################
# Vector update
"""
    updateallcontent!(value, string, node, amlType)

Finds all the elements with the address of string in the node, and updates the content
"""
function updateallcontent!(value::Vector{T}, s::String, node::Union{Node, Document}, amlType::Int64) where{T<:Union{String, Number, Bool}} # for stringsm numbers, and bool


    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elmsNode = findall(s, node) # a vector of Node elements
        else
            elmsNode = findalllocal(s, node) # a vector of Node elements
        end

        if isnothing(elmsNode) # error if nothing is found
            return error("field not found in aml")
        else
            i = 1
            for elm in elmsNode
                elm = value[i]
                i+=1
            end
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elmsNode = node[s]
            i = 1
            for elm in elmsNode
                elm = value[i]
                i+=1
            end
        else # error if nothing is found
            return error("field not found in aml")
        end
    end
end

# for defined types and nothing
function updateallcontent!(value::Vector{T}, s::String, node::Union{Node, Document}, amlType::Int64) where{T}

    if amlType == 0 # normal elements

        if typeof(node) == Document || hasdocument(node)
            elmsNode = findall(s, node) # a vector of Node elements
        else
            elmsNode = findalllocal(s, node) # a vector of Node elements
        end

    elseif amlType == 2 # Attributes

        if haskey(node, s)
            elmsNode = node[s]
        else # error if nothing is found
            return error("field not found in aml")
        end
    end


    if isnothing(elmsNode) # error if nothing is found
        return error("field not found in aml")
    else
        i = 1
        for elm in elmsNode
            if isnothing(value[i])
                unlink!(elm)
            else
                if hasmethod(string, Tuple{T})
                    elm.content = string(value[i])
                else
                    unlink!(elm)
                    link!(node, value[i].aml)
                end
            end
            i+=1
        end
        return elmsType
    end

end

################################################################
# doc or element initialize
"""
    docOrElmInit(name)
    docOrElmInit(type, name)

Function to initialize the aml

type:
0 : element node # default
10: empty element node
-1: xml
-2: html
"""
function docOrElmInit(type::Int64 = 0, name::String = nothing)

    if type == 0 # element node

        out = ElementNode(name)

    elseif type == 10 # empty element node

        out = ElementNode(name)

    elseif type == -1 # xml

        out = XMLDocument() # version 1

    elseif type == -2 # html

        out = HTMLDocument() # no URI and external id
    end

    return out
end
################################################################
# moved to my fork of EzXML
# function Base.print(x::Node)
#     println("")
#     prettyprint(x)
# end
# function Base.print(x::Document)
#     println("")
#     prettyprint(x)
# end
