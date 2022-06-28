import Foundation

public protocol EditableCompound: ViewableCompound
where InnerGraph: EditableGraph, InnerTree: EditableTree
{
    
}
