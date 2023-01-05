<!------------------------------------------------------------------------------------------------------
  An individual Item from a list of items
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    // @ts-nocheck

	import { SimpleGrid, Button, Card, Image, Text, Divider, Affix } from '@svelteuidev/core';
    import type { Item, ItemDetails, Person } from './Graphql.svelte';
    import QRcode from './QRcode.svelte';
	import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let item : Item                          // Details about the item
    export let loggedIn : boolean;                  // Whether the user is logged in or not
    export let available : boolean;                 // Whether the item is available to be booked
    export let upi : string;                        // Logged in user's UPI
    export let qrcode : boolean;                    // Show the QR code for the item instead of the picture

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // Check the list of inductions to see if user is allowed to book this item
    // function allowed () : boolean {
    //     return (item.inductions.reduce((acc : boolean, curr : Person) => acc || (curr.upi === upi), false))
    // }

    $: allowed = (item.inductions.reduce((acc : boolean, curr : Person) => acc || (curr.upi === upi), false));

    function getName (details : ItemDetails, name : string) : string {
        return (details.name ? details.name : name);
    }

    // Work out an appropriate message.  The loggedin parameter is to ensure this is updated when the user logs in.
    function getAccessMessage(_loggedIn, available) : string {
        let returnString : string;
        if (available) {
            switch (item.access.toString()) {
                case "FREE" : returnString = "You can book this item without induction."; break;
                case "INDUCTION" : 
                    if (allowed) {
                        returnString = "You can book this item."
                    }else{
                        returnString = "You must be inducted to book this item";
                    }
                    break;
                default : returnString = "This item can only be used under supervision."; break;
            }
        }
        else {
            returnString = "This item is currently booked.";
        }
        return (returnString);
    }

    function bookItem () { dispatch ( 'book', { item : item } ) }

    function showDetails () { dispatch ( 'showDetails', { item : item } ) }

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
    {#if qrcode}
        <QRcode queryVars={{qrcode: item.name}}/>
    {:else}
        <Image src={item.image} alt={item.name} fit=contain/>
        <Divider variant='dotted'/>
        <Card.Section>

            <Text align='center' size='lg' weight={500}>
                {getName(item.details, item.name)}
            </Text>

            <Divider variant='dotted'/>

            <Text align='center' size='sm'>
                {getAccessMessage(loggedIn, available)}
            </Text>
        
            <Divider variant='dotted'/>

            <Text align='center' size='sm'>
                {item.name.toUpperCase()}
            </Text>
        
            <Divider variant='dotted'/>
        </Card.Section>
    
        <SimpleGrid cols={2}>
            <Button on:click={showDetails} variant='filled' color='blue' fullSize>
                Details
            </Button>
            {#if (loggedIn && available && (allowed || (item.access.toString() == "FREE")))}
                <Button on:click={bookItem} variant='filled' color='green' fullSize>
                    Book
                </Button>
            {:else if (loggedIn && !available && (allowed || (item.access.toString() == "FREE")))}
                <Button on:click={bookItem} variant='filled' color='yellow' fullSize>
                    Book
                </Button> 
            {:else if !available} 
                <Button on:click={bookItem} variant='filled' color='yellow' fullSize>
                    Bookings
                </Button>
            {:else}
                <Button on:click={bookItem} variant='filled' color='orange' fullSize>
                    Bookings
                </Button>
            {/if}
        </SimpleGrid>
    {/if}
</Card>
<!----------------------------------------------------------------------------------------------------->
