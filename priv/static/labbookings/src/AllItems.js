import React, { Component } from 'react';
import Item from './Item'
import 'semantic-ui-css/semantic.min.css';
import { Card, Header, Menu, Input } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Show all the items
// ----------------------------------------------------------------------------------------------------
class AllItems extends Component
{
    handleChange = (e, { name, value }) => { this.setState({ [name]: value }); }
  
    handleSubmit = () => {
        const { search } = this.state;
    }

    constructor(props) {
        super (props);
        this.state = { search: '' };
    }

    ItemCards = (data) => {
        return (
            data.data.itemAll.map(({ name, url, image, bookable, access, details }) => {
                if (bookable && (name.includes(this.state.search) || (this.state.search === ""))) {
                    return (<Item name={name} url={url} image={image} bookable={bookable} access={access} details={details} />)
                }
            })
        )
    }
    //     var returnData = "";

    //     returnData = data.data.itemAll.map(({ name, url, image, bookable, access, details }) => {

    //         <Item name={name} url={url} image={image} bookable={bookable} access={access} details={details}/>

    //         // if (name.includes(this.state.search) || (this.state.search === "")) {
    //         //     console.log(name);
    //         //     ( <Item name={name} url={url} image={image} bookable={bookable} access={access} details={details}/>)
    //         // }
    //         // else{
    //         //     ( <Item name={"TEST"} url={url} image={image} bookable={bookable} access={access} details={details}/>)
    //         // }
    //     })

    //     console.log(returnData);
    //     return (returnData);
    // }


    render ()
    {
        console.log("rendering")
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    All items
                </Header>
                <Menu fluid widths={1}>
                    <Menu.Item>
                        <Input name='search' icon='search' placeholder='Search for item...' onChange={this.handleChange} />
                    </Menu.Item>
                </Menu>
                <Card.Group centered>
                    <this.ItemCards data={this.props.data} />
                </Card.Group>
            </>
        )
    }
}

export default AllItems;
// ----------------------------------------------------------------------------------------------------
