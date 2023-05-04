![](meta/icon.png)

## Studding

Studding is a very fast, very memory efficient Swift XML deserializer useful for embedding into other Swift XML tools. Studding is middleware which provides a hierarchical data structure suitable for generically accessing an XML blob with minimal overhead.

- Order Preserving  
Dictionaries in Swift are naturally unordered. Studding, being a tool which other tools rely on, preserves the ordering of the data structure to match how it is in the underlying data.

- Memory Efficiency  
The data structures used by Studding do not make any copies from the original XML blob, which reduces the processing overhead dramatically.

