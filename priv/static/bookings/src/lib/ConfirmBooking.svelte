<!------------------------------------------------------------------------------------------------------
  A login dialog box
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { mutation, getClient } from 'svelte-apollo';
    import { Card, Divider, Input, Button, SimpleGrid, Text } from '@svelteuidev/core';
    import { ITEMCHANGEBOOKING, ITEMBOOK } from './Graphql.svelte';
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
    export let sessionid : string;                          // Current sessionid

    export let success : (item : Item) => null;             // Called when success in updating or new
    export let closeDialog : () => null;                    // Close the dialog box (eg when cancel pressed)

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let errorMessage : string = "";                         // Error message from attempted booking

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------

    // Functions for changing an existing booking
    const ItemChangebooking = mutation(ITEMCHANGEBOOKING, {
        context : { headers : { sessionid : sessionid } },
        fetchPolicy: 'network-only'
    });
    const handleUpdate = () => {
        ItemChangebooking({ variables: { itemname:itemName, upi, starttime:startTime, endtime:endTime, newstarttime:newStartTime, newendtime:newEndTime, details:"{}" } })
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
        ItemBook({ variables: { itemname:itemName, upi, starttime:startTime, endtime:endTime, details:"{}" } })
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

    <Input placeholder='Start Time' value={newStartTime}/>
    <Divider variant='dotted'/>
    <Input placeholder='End Time' value={newEndTime} />
    <Divider variant='dotted'/>
    <Input placeholder='Item Name' value={itemName.toUpperCase()} />
    <Divider variant='dotted'/>

    <SimpleGrid cols={2}>
        <Button on:click={closeDialog} variant='filled' color='blue' fullSize>
            Cancel
        </Button>
        {#if updating}
            <Button on:click={handleUpdate} variant='filled' color='green' fullSize>
                Update Booking
            </Button>
        {:else}
            <Button on:click={handleNew} variant='filled' color='green' fullSize>
                New Booking
            </Button>
        {/if}
    </SimpleGrid>
</Card>
<!----------------------------------------------------------------------------------------------------->