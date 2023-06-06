<!------------------------------------------------------------------------------------------------------
  A login dialog box
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { mutation } from 'svelte-apollo';
    import { Card, Divider, Center, Input, Button, Grid, Text } from 'svelte-fomantic-ui';
    import { ITEMCHANGEBOOKING, ITEMBOOK, ITEMUNBOOK } from './Graphql.svelte';
    import type { Item } from './Graphql.svelte';
    import { convertErrorMessage } from './ErrorMessages.svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let itemName : string;                           // The item name
    export let upi : string;                                // the UPI of the person the item is being booked for
    export let startTime : string;                          // A start time
    export let endTime : string;                            // An end time
    export let newStartTime : string;                       // A new start time (when updating)
    export let newEndTime : string;                         // A new end time (when updating)
    export let updating : boolean;                          // Whether updating or creating new
    export let editing : boolean;                           // Whether editing an existing booking
    export let sessionid : string;                          // Current sessionid
    export let details : any;                               // Additional booking details
    export let bookingupi : string;                         // The upi to book for
    export let bookerStatus : string;                       // The status of the person booking

    export let success : (item : Item) => null;             // Called when success in updating or new
    export let closeDialog : () => null;                    // Close the dialog box (eg when cancel pressed)

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let errorMessage : string = "";                             // Error message from attempted booking
    let bookingInfo : string = details.info ? details.info : "";

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------

    // Functions for changing an existing booking
    const ItemChangebooking = mutation(ITEMCHANGEBOOKING, {
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });
    const handleUpdate = () => {
        ItemChangebooking({ variables: { itemname:itemName, upi:bookingupi, starttime:startTime, endtime:endTime, newstarttime:newStartTime, newendtime:newEndTime, details:"{\"info\":\"" + bookingInfo + "\"}" } })
        .then((result : any) => {
            success(result.data.itemChangebooking);
        })
        .catch((error) => {
            console.log(error);
            errorMessage = convertErrorMessage(error.graphQLErrors[0].message);
        });
    }

    // Functions for creating a new booking
    const ItemBook = mutation(ITEMBOOK, {
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });
    const handleNew = () => {
        ItemBook({ variables: { itemname:itemName, upi:bookingupi, starttime:startTime, endtime:endTime, details:"{\"info\":\"" + bookingInfo + "\"}" } })
        .then((result : any) => {
            success(result.data.itemBook);
        })
        .catch((error) => {
            console.log(error);
            errorMessage = convertErrorMessage(error.graphQLErrors[0].message);
        });
    }

    // Functions for deleting a booking
    const ItemUnbook = mutation(ITEMUNBOOK, {
    context : { headers : { sessionid : sessionid } },
    fetchPolicy: 'network-only'
    });
    const handleDelete = () => {
        ItemUnbook({ variables: { itemname:itemName, upi:bookingupi, starttime:startTime, endtime:endTime } })
        .then((result : any) => {
            success(result.data.itemBook);
        })
        .catch((error) => {
            console.log(error);
            errorMessage = convertErrorMessage(error.graphQLErrors[0].message);
        });
    }
</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>

</style>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
<Card p="lg">
    {#if errorMessage}
        <Text size='md' color='red' align='center'>
            {errorMessage}
        </Text>
        <Divider variant='dotted'/>
    {/if}

    {#if bookerStatus === "ADMIN" || bookerStatus === "POWERUSER"}
        <Input placeholder="Booking for..." bind:value={bookingupi}/>
        <Divider variant='dotted'/>
    {/if}
    <Input placeholder="Additional Booking Details" bind:value={bookingInfo}/>
    <Divider variant='dotted'/>
    <Grid cols={2}>
        <Button on:click={closeDialog} variant='filled' color='blue' fullSize>
            Cancel
        </Button>
        {#if updating || editing}
            <Button on:click={handleUpdate} variant='filled' color='green' fullSize>
                Update
            </Button>
        {:else}
            <Button on:click={handleNew} variant='filled' color='green' fullSize>
                New
            </Button>
        {/if}
    </Grid>
    {#if editing}
        <Divider variant='dotted'/>
        <Center>or</Center>
        <Divider variant='dotted'/>
        <Grid cols={1}>
            <Button on:click={handleDelete} variant='filled' color='red' fullSize>
                Delete
            </Button>        
        </Grid>
    {/if}
</Card>
<!----------------------------------------------------------------------------------------------------->