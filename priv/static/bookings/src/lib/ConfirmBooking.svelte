<!------------------------------------------------------------------------------------------------------
  A login dialog box
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { mutation } from 'svelte-apollo';
    import { Input, Button, Header, Message , Content, Form, Field, Label, Actions, Text } from 'svelte-fomantic-ui';
    import { ITEMCHANGEBOOKING, ITEMBOOK, ITEMUNBOOK } from './Graphql.svelte';
    import type { Item } from './Graphql.svelte';
    import { convertErrorMessage } from './ErrorMessages.svelte';
    import dayjs from 'dayjs'

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
    export let title: string;                               // Title of the dialog box

    export let success : (item : Item) => null;             // Called when success in updating or new
    export let closeDialog : () => null;                    // Close the dialog box (eg when cancel pressed)

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let errorMessage : string = "";                             // Error message from attempted booking
    let bookingInfo : string = details.info ? details.info : "";
    const offsetMinutes = new Date(startTime).getTimezoneOffset();

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
            errorMessage="";
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
            errorMessage="";
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
            errorMessage="";
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
<Header>{title}</Header>
<Content>
    <Form ui>
        <Field>
            <Label input>Start</Label>
            <Text>{dayjs(new Date(new Date(newStartTime).getTime() - offsetMinutes * 60000)).format('MMMM DD, YYYY, HH:mm')}</Text>
        </Field>
        <Field>
            <Label input>End</Label>
            <Text>{dayjs(new Date(new Date(newEndTime).getTime() - offsetMinutes * 60000)).format('MMMM DD, YYYY, HH:mm')}</Text>
        </Field>
        {#if bookerStatus === "ADMIN" || bookerStatus === "POWERUSER"}
            <Field>
                <Label input>User name</Label>
                <Input placeholder="Booking for..." bind:value={bookingupi}/>
            </Field>
        {/if}
        <Field>
            <Label input>Details</Label>
            <Input placeholder="Additional Booking Details" bind:value={bookingInfo}/>
        </Field>
    </Form>
    {#if errorMessage!==""}
        <Message ui error>{errorMessage}</Message>
    {/if}
</Content>
<Actions>
    <Button ui blue on:click={ () => {errorMessage=""; closeDialog(); }}>
        Cancel
    </Button>
    {#if updating || editing}
        <Button ui green on:click={handleUpdate}>
            Update
        </Button>
    {:else}
        <Button ui green on:click={handleNew}>
            New
        </Button>
    {/if}
    {#if editing}
        <Button ui red on:click={handleDelete}>
            Delete
        </Button>
    {/if}      
</Actions>
<!----------------------------------------------------------------------------------------------------->