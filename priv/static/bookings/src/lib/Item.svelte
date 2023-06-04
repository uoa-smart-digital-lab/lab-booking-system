<script lang="ts">
    import { Card, Item, Content, Image, Header, Buttons, Button, Description, Extra} from "svelte-fomantic-ui";
    import type { Item as ItemT, ItemDetails } from './Graphql.svelte';

    export let item: ItemT;
    export let ui = false;

    export let list = false;

    // Get the name from the details if it exists, otherwise return an empty string rather than undefined
    function getname (details : ItemDetails) : string { return(details.name ? details.name : ""); }
</script>

<Card {ui}>
    <Content style={list?"display:flex; align-items: center;":""}>
        <Image ui _={list?"small":""} src={item.image}/>
    </Content>
    <Content style={list?"display:flex; align-items: center;":""}>
        <Header _={list?"":"center aligned"}>{getname(item.details)}</Header>
    </Content>
    <Content style={list?"display:flex; align-items: center;":""}>
        <Description _={list?"":"center aligned"}>{item.name.toUpperCase()}</Description>
    </Content>
    {#if list}
        <Content style={"display:flex; align-items: center;"}>
            <Buttons ui wrapping two buttons>
                <Button ui primary>book</Button>
                <Button ui green>info</Button>
            </Buttons>
        </Content>
    {:else}
        <Buttons ui wrapping two buttons bottom attached>
            <Button ui primary>book</Button>
            <Button ui green>info</Button>
        </Buttons>
    {/if}
</Card>
