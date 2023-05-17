local ffi = require("ffi")


ffi.cdef([[
    
    typedef unsigned short PlayerIndex;

    typedef struct {            
        int binaryAddress;        
        unsigned short port;

        // PlayerID& operator = (const PlayerID& input)
        // {
            // binaryAddress = input.binaryAddress;
            // port = input.port;
            // return *this;
        // }

        // bool operator==(const PlayerID& right) const;
        // bool operator!=(const PlayerID& right) const;
        // bool operator > (const PlayerID& right) const;
        // bool operator < (const PlayerID& right) const;                
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