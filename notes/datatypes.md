GROUP: {ADMIN, SUPER, STAFF, STUDENT}
RESTRICT: {NONE, INDUCTION, SUPERVISED}

BOOKING:
    begin: datetime
    end: datetime


PERSON
    upi: string                         // Unique ID
    details: json                       // Various details
    group: GROUP                        // Group the user belongs to
    inductions: [ITEM]                  // List of items person has been trained to use

ITEMGROUP
    name: string                        // Unique name of then item group
    details: json                       // Various details
    access: RESTRICT                    // Level of access required to use item
    items: [ITEM]                       // Items in the group 

ITEM
    name: string                        // Unique name of the item
    details: json                       // Various details
    access: RESTRICT                    // Level of access required to use item
    bookings: [BOOKING]                 // Times this item is booked


/api
/$ITEM/qr        // QR code for this item
/bookings/$upi

