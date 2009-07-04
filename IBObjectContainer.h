//      Framework:      InterfaceBuilder
//      Header:         Unknown
//      Documentation:  Unknown
//
//  Thanks to jay Tuley for making this available at
//      http://www.indyjt.com/wiki/pmwiki.php/Tutorials/IBObjectContainer

@interface IBObjectContainer : NSObject <NSCoding>
{
        unsigned short          _version;
        NSMutableDictionary*    auxiliaryObjects;
        void*                   cidTable;
        void*                   classTable;
        NSMutableSet*           connectors;
        NSMutableDictionary*    groups;
        void*                   nameTable;
        void*                   objectTable;
        void*                   oidTable;
        NSMutableSet*           visibleWindows;
}

+ (void) initialize;

- (void) _encodeMapTable: (void*) parameter1 forTypes: (char*) parameter2 withCoder: (id) parameter3;
- (void) _keyEncodeObjectToIntMapTable: (void*) parameter1 withKey: (id) parameter2 inCoder: (id) parameter3;
- (void) _keyEncodeObjectToObjectMapTable: (void*) parameter1 withKey: (id) parameter2 inCoder: (id) parameter3;
- (void) addConnector: (id) parameter1;
- (void) addGroup: (id) parameter1 forID: (id) parameter2;
- (void) addObject: (id) parameter1;
- (void) addObject: (id) parameter1 withParent: (id) parameter2;
- (void) addVisibleWindow: (id) parameter1;
- (id) auxiliaryObjectForKey: (id) parameter1;
- (id) classNameForObject: (id) parameter1;
- (int) connectorIDForConnector: (id) parameter1;
- (id) connectors;
- (char) containsObject: (id) parameter1;
- (void) dealloc;
- (void*) decodeObjectToIntMapTableForKey: (id) parameter1 fromCoder: (id) parameter2 alwaysCreate: (char) parameter3;
- (void*) decodeObjectToObjectMapTableForKey: (id) parameter1 fromCoder: (id) parameter2 alwaysCreate: (char) parameter3;
- (id) description;
- (id) descriptionWithLocale: (id) parameter1;
- (id) descriptionWithLocale: (id) parameter1 indent: (unsigned int) parameter2;
- (void) encodeWithCoder: (id) parameter1;
- (id) groups;
- (id) init;
- (id) initWithCoder: (id) parameter1;
- (id) nameForObject: (id) parameter1;
- (id) objectForObjectID: (int) parameter1;
- (int) objectIDForObject: (id) parameter1;
- (id) objects;
- (id) objectsWithParent: (id) parameter1;
- (id) parentOfObject: (id) parameter1;
- (id) rootObjects;
- (void) setAuxiliaryObject: (id) parameter1 forKey: (id) parameter2;
- (void) setClassName: (id) parameter1 forObject: (id) parameter2;
- (void) setConnectorID: (int) parameter1 forConnector: (id) parameter2;
- (void) setName: (id) parameter1 forObject: (id) parameter2;
- (void) setObjectID: (int) parameter1 forObject: (id) parameter2;
- (id) visibleWindows;

@end
