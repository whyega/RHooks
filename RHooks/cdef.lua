local ffi = require("ffi")


ffi.cdef([[    
    typedef unsigned short PlayerIndex;

    typedef struct {            
        int binaryAddress;        
        unsigned short port;                    
    } PlayerID;

    typedef struct {                   
        PlayerIndex playerIndex;        
        PlayerID playerId;  

        unsigned int length;       
        unsigned int bitSize; 
               
        unsigned char* data;       
        bool deleteData;              
    } Packet;    
]])