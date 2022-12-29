<!------------------------------------------------------------------------------------------------------
An individual Item from a list of items
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck

	import { SimpleGrid, Button, Card, Image, Text, Divider } from '@svelteuidev/core';
    import Booking from "./Booking.svelte";

    export let item;            // Details about the item itself
    export let loggedin;        // Whether the user is logged in or not

    export let bookitem;        // The funcion to call when the book item button is pressed

    const getname = (details, name) => details.name ? details.name : name;

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
<Card shadow="md" p="lg">
    <Image src={item.image} alt={item.name} />

    <Card.Section>
        <Divider variant='dotted'/>

        <Text align='center' size='lg' weight={500}>
            {getname(item.details, item.name)}
        </Text>
    
        <Divider variant='dotted'/>
    
        <Text align='center' size='sm'>
            {item.name.toUpperCase()}
        </Text>
    
        <Divider variant='dotted'/>
    </Card.Section>

    <SimpleGrid cols={loggedin?2:1}>
        <Button variant='filled' color='blue' fullSize>
            Details
        </Button>
        {#if loggedin}
            <Button on:click={() => {bookitem(item);}} variant='filled' color='green' fullSize>
                Booking
            </Button>
        {/if}
    </SimpleGrid>
</Card>
<!----------------------------------------------------------------------------------------------------->
