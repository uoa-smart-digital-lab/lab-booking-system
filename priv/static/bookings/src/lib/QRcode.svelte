<!------------------------------------------------------------------------------------------------------
An individual Item's qrcode
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck

	import { SimpleGrid, Button, Card, Image, Text, Divider } from '@svelteuidev/core';
    import QrCode from "svelte-qrcode";
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';

    export let itemname;         // Details about the item itself

    let qrlink = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?item=" + itemname;

    let item = query(ITEMGET, {
      variables: {name: itemname}
    });

    function getname (details, name) {
        return (details.name ? details.name : name);
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
{#if $item.loading}
    Loading...
{:else if $item.error}
    Error: {$item.error.message}
{:else}
    <Card shadow="md" p="lg">
        <QrCode value={qrlink} />

        <Card.Section>
            <Divider variant='dotted'/>

            <Text align='center' size='lg' weight={500}>
                {getname($item.data.itemGet.details, $item.data.itemGet.name)}
            </Text>
        
            <Divider variant='dotted'/>
        
            <Text align='center' size='sm'>
                {itemname}
            </Text>
        </Card.Section>
    </Card>
{/if}
<!----------------------------------------------------------------------------------------------------->
