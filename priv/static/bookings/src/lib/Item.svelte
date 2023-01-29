<!------------------------------------------------------------------------------------------------------
  An individual Item from a list of items
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    // @ts-nocheck

	import { SimpleGrid, Button, Card, Image, Text, Divider, Grid } from '@svelteuidev/core';
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
    export let list : boolean;                      // True if list mode, otherwise display as card

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // Check the list of inductions to see if user is allowed to book this item
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
{#if list}
    <Grid override={{padding:'10px'}} >
        <Grid.Col span={2}>
            <Image src={item.image} alt={item.name} fit=contain/>
        </Grid.Col>
        <Grid.Col override={{display:'flex', 'align-items':'center'}} span={3}>
            {#if item.details.name}
            <SimpleGrid spacing={2} cols={1}>
                <Text align='left' weight='bold' size='lg'>
                    {getName(item.details, item.name)}
                </Text>
                <Text align='left' size='xs'>
                    {item.name.toUpperCase()}
                </Text>
            </SimpleGrid>
            {:else}
                <Text override={{display:'grid', 'align-items':'center'}} align='left' weight='bold'>
                    {item.name.toUpperCase()}
                </Text>
            {/if}
        </Grid.Col>
        <Grid.Col override={{display:'grid', 'align-items':'center'}} span={4}>
            <Text override={{display:'grid', 'align-items':'center'}} align='left' size='sm'>
                {getAccessMessage(loggedIn, available)}
            </Text>
        </Grid.Col>
        <Grid.Col override={{display:'grid', 'align-items':'center'}} span={3}>
            <SimpleGrid spacing={5} cols={1}>
                <Button compact on:click={showDetails} variant='filled' color='blue' fullSize>
                    Details
                </Button>
                {#if (loggedIn && available && (allowed || (item.access.toString() == "FREE")))}
                    <Button compact on:click={bookItem} variant='filled' color='green' fullSize>
                        Book
                    </Button>
                {:else if (loggedIn && !available && (allowed || (item.access.toString() == "FREE")))}
                    <Button compact on:click={bookItem} variant='filled' color='yellow' fullSize>
                        Book
                    </Button> 
                {:else if !available} 
                    <Button compact on:click={bookItem} variant='filled' color='yellow' fullSize>
                        Bookings
                    </Button>
                {:else}
                    <Button compact on:click={bookItem} variant='filled' color='orange' fullSize>
                        Bookings
                    </Button>
                {/if}
            </SimpleGrid>
        </Grid.Col>
    </Grid>
{:else if qrcode}
    <Card p="lg">
        <QRcode queryVars={{qrcode: item.name}}/>
    </Card>
{:else}
    <Card p="lg">
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
    </Card>
{/if}
<!----------------------------------------------------------------------------------------------------->
