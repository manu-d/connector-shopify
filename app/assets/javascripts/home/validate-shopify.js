$(document).ready(function () {
    $('#authentify-shopify').bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            shop: {
                message: 'The username is not valid.',
                validators: {
                    notEmpty: {
                        message: 'The shop is mandatory'
                    },
                    callback: {
                        message: 'Not ending with myshopify.com',
                        callback: function (value, validator, $field) {
                            return value.endsWith('.myshopify.com')
                        }
                    }
                },
                verbose:false
            }
        }
    })
});

