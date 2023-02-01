<script lang="ts">
	import { RevoGrid } from '@revolist/svelte-datagrid';
</script>

<style>
    revo-grid {
		height: 100vh !important;
	}
</style>

<RevoGrid source={[
    {
        prop: "name",
        name: "First",
    },
    {
        prop: "details",
        name: "Second",
    }
]} resize="true" columns={[
    {
        name: "1",
        details: "Item 1",
    }
]}/>
