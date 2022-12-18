import React, { Component } from 'react';
import Item from './Item'
import 'semantic-ui-css/semantic.min.css';
import { Card, Header } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Show all the items
// ----------------------------------------------------------------------------------------------------
class AllItems extends Component
{
    handleChange = (e, { name, value }) => this.setState({ [name]: value })
  
    handleSubmit = () => {
        const { upi, name } = this.state;
    }

    constructor(props) {
        console.log(props);
        super (props);
        this.state = { upi: '', name: '' };
    }

    ItemCards = (data) => {
        return (
            data.data.itemAll.map(({ name, url, image, bookable, access, details }) => (
                <Item name={name} url={url} image={image} bookable={bookable} access={access} details={details}/>))
        )
    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    All items
                </Header>
                <Card.Group centered>
                    <this.ItemCards data={this.props.data} />
                </Card.Group>
            </>
        )
    }
}

export default AllItems;
// ----------------------------------------------------------------------------------------------------
