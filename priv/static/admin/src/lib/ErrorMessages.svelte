<!------------------------------------------------------------------------------------------------------
  Error Messages
------------------------------------------------------------------------------------------------------->
<script context="module" lang="ts">
    export const convertErrorMessage = (error : string) : string => {
        console.log(error);
        switch (error) {
            case 'badpassword'  : return "Incorrect Login Details"; break;
            case 'nosession'    : return "Incorrect Login Details"; break;
            case 'overlap'      : return "Booking overlaps another"; break;
            case 'notinducted'  : return "You are not allowed to book this item"; break;
            case 'notexist'     : return "This booking doesn't exist"; break;
            case 'notallowed'   : return "This booking cannot be modified or deleted by you"; break;
            case 'notbookable'  : return "This item cannot be booked"; break;
            default             : return "Error"; break;
        }
    }
</script>