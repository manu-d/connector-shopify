$(document).ready(function () {
    $('#authentify-shopify').bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            shop: {
                validators: {
                    notEmpty: {
                        message: 'Shop domain is mandatory'
                    },
                    callback: {
                        callback: function (value, validator, $field) {
                            value = value.trim();
                            if (value.endsWith('.myshopify.com')){
                                return {
                                    valid: false,
                                    message: 'No need to add ".myshopify.com", we are taking care of it'
                                }
                            }else if (value.startsWith('http')){
                                return {
                                    valid: false,
                                    message: 'No need to add the "http", we are taking care of it'
                                }
                            }
                            return true;
                        }
                    }
                },
                verbose:false
            }
        }
    })
});

