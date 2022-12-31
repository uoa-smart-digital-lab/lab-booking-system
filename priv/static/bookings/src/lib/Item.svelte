<!------------------------------------------------------------------------------------------------------
  An individual Item from a list of items
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    // @ts-nocheck

	import { SimpleGrid, Button, Card, Image, Text, Divider } from '@svelteuidev/core';
    import type { Item, ItemDetails, Person } from './Graphql.svelte';
    import { Access } from './Graphql.svelte';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let item : Item                          // Details about the item
    export let loggedIn : boolean;                  // Whether the user is logged in or not
    export let upi : string;                        // Logged in user's UPI
    export let bookItem: (item : Item) => void      // The funcion to call when the book item button is pressed

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    const getName = (details : ItemDetails, name : string) : string => details.name ? details.name : name;

    const getAccessMessage = (access : string, inductions : [ Person ], upi : string) : string => {
        switch (access) {
            case "FREE" : return "You can book this item without induction."; break;
            case "INDUCTION" : 
                if (inductions.reduce((acc, curr) => acc || (curr.upi === upi), false)){
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

    <Card.Section>
        <Divider variant='dotted'/>

        <Text align='center' size='lg' weight={500}>
            {getName(item.details, item.name)}
        </Text>
    
        <Divider variant='dotted'/>

        <Text align='center' size='sm'>
            {getAccessMessage(item.access.toString(), item.inductions, upi)}
        </Text>
        
        <Divider variant='dotted'/>

        <Text align='center' size='sm'>
            {item.name.toUpperCase()}
        </Text>
    
        <Divider variant='dotted'/>
    </Card.Section>

    <SimpleGrid cols={loggedIn?2:1}>
        <Button variant='filled' color='blue' fullSize>
            Details
        </Button>
        {#if loggedIn}
            <Button on:click={() => {bookItem(item)}} variant='filled' color='green' fullSize>
                Booking
            </Button>
        {/if}
    </SimpleGrid>
</Card>
<!----------------------------------------------------------------------------------------------------->
