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
        const { upi, name } = this.state;
    }

    constructor(props) {
        console.log(props);
        super (props);
        this.state = { search: '' };
    }

    ItemCards = (data) => {
        return (
            data.data.itemAll.map(({ name, url, image, bookable, access, details }) => {
                if (name.includes(this.search) || (this.search === "")) {
                    ( <Item name={name} url={url} image={image} bookable={bookable} access={access} details={details}/>)
                }
            })
        )
    }


    render ()
    {
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
