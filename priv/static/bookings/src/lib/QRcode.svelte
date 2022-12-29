<!------------------------------------------------------------------------------------------------------
An individual Item's qrcode
------------------------------------------------------------------------------------------------------->
<script>
    // @ts-nocheck

	import { SimpleGrid, Button, Card, Image, Text, Divider } from '@svelteuidev/core';
    import QrCode from "svelte-qrcode";
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';

    export let itemname;            // Details about the item itself
    export let qrsearch;            // QR Code for a qrsearch instead of a specific item

    let qrlink = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?" + (qrsearch?"search=" + qrsearch:"item=" + itemname);

    let item;
    if (!qrsearch) {
        item = query(ITEMGET, {
            variables: {name: itemname}
        });
    }

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
{#if qrsearch}
    <a href = {qrlink}>
        <QrCode value={qrlink} alt={qrlink}/>
    </a>

    <Divider variant='dotted'/>

    <Text align='center' size='sm'>
        {qrsearch}
    </Text>
{:else}
    {#if $item.loading}
        Loading...
    {:else if $item.error}
        Error: {$item.error.message}
    {:else}
        <a href = {qrlink}>
            <QrCode value={qrlink} alt={qrlink}/>
        </a>

        <Divider variant='dotted'/>

        <Text align='center' size='lg' weight={500}>
            {getname($item.data.itemGet.details, $item.data.itemGet.name)}
        </Text>

        <Divider variant='dotted'/>

        <Text align='center' size='sm'>
            {itemname.toUpperCase()}
        </Text>
    {/if}
{/if}
<!----------------------------------------------------------------------------------------------------->
