<!------------------------------------------------------------------------------------------------------
  An individual Item from a list of items
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    // @ts-nocheck

	import { SimpleGrid, Button, Card, Image, Text, Divider, Affix } from '@svelteuidev/core';
    import type { Item, ItemDetails, Person } from './Graphql.svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let item : Item                          // Details about the item
    export let loggedIn : boolean;                  // Whether the user is logged in or not
    export let available : boolean;                 // Whether the item is available to be booked
    export let upi : string;                        // Logged in user's UPI
    export let bookItem : (item : Item) => void;    // The funcion to call when the book item button is pressed
    export let showItem : (url : string) => void;   // The funcion to call when the item details button is pressed

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // Check the list of inductions to see if use is allowed to book this item
    const allowed = (_loggedIn : boolean) : boolean => (item.inductions.reduce((acc : boolean, curr : Person) => acc || (curr.upi === upi), false));

    const getName = (details : ItemDetails, name : string) : string => details.name ? details.name : name;

    const getAccessMessage = (loggedIn) : string => {
        switch (item.access.toString()) {
            case "FREE" : return "You can book this item without induction."; break;
            case "INDUCTION" : 
                if (allowed(loggedIn)) {
                    return "You are allowed to book this item.";
                }else{
                    return "You must be inducted to book this item";
                }
                break;
            default : return "This item can only be used under supervision."; break;
        }
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
        <Image src={item.image} alt={item.name} fit=contain/>

        <Divider variant='dotted'/>
    <Card.Section>

        <Text align='center' size='lg' weight={500}>
            {getName(item.details, item.name)}
        </Text>

        <Divider variant='dotted'/>

        <Text align='center' size='sm'>
            {getAccessMessage(loggedIn)}
        </Text>
     
        <Divider variant='dotted'/>

        <Text align='center' size='sm'>
            {item.name.toUpperCase()}
        </Text>
    
        <Divider variant='dotted'/>
    </Card.Section>
 
    <SimpleGrid cols={2}>
        <Button on:click={() => {showItem(item.url)}} variant='filled' color='blue' fullSize>
            Details
        </Button>
        {#if (loggedIn && available && (allowed() || (item.access.toString() == "FREE")))}
            <Button on:click={() => {bookItem(item)}} variant='filled' color='green' fullSize>
                Book
            </Button>
        {:else if (loggedIn && !available && (allowed() || (item.access.toString() == "FREE")))}
            <Button on:click={() => {bookItem(item)}} variant='filled' color='yellow' fullSize>
                Book
            </Button> 
        {:else} 
            <Button on:click={() => {bookItem(item)}} variant='filled' color='orange' fullSize>
                Availability
            </Button>      
        {/if}
    </SimpleGrid>
</Card>
<!----------------------------------------------------------------------------------------------------->
