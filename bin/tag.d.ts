import * as pulumi from "@pulumi/pulumi";
export declare class Tag extends pulumi.CustomResource {
    /**
     * Get an existing Tag resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param state Any extra arguments used during the lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    static get(name: string, id: pulumi.Input<pulumi.ID>, state?: TagState, opts?: pulumi.CustomResourceOptions): Tag;
    /**
     * Returns true if the given object is an instance of Tag.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is Tag;
    /**
     * Description of the feature
     */
    readonly description: pulumi.Output<string | undefined>;
    /**
     * ID of the project
     */
    readonly projectId: pulumi.Output<number>;
    /**
     * UUID of project the tag belongs to
     */
    readonly projectUuid: pulumi.Output<string>;
    /**
     * Colour for this tag, as accepted by [color-string](https://github.com/Qix-/color-string).
     */
    readonly tagColour: pulumi.Output<string>;
    /**
     * ID of the tag
     */
    readonly tagId: pulumi.Output<number>;
    /**
     * Name of the tag
     */
    readonly tagName: pulumi.Output<string>;
    /**
     * UUID of the tag
     */
    readonly uuid: pulumi.Output<string>;
    /**
     * Create a Tag resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: TagArgs, opts?: pulumi.CustomResourceOptions);
}
/**
 * Input properties used for looking up and filtering Tag resources.
 */
export interface TagState {
    /**
     * Description of the feature
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * ID of the project
     */
    projectId?: pulumi.Input<number | undefined>;
    /**
     * UUID of project the tag belongs to
     */
    projectUuid?: pulumi.Input<string | undefined>;
    /**
     * Colour for this tag, as accepted by [color-string](https://github.com/Qix-/color-string).
     */
    tagColour?: pulumi.Input<string | undefined>;
    /**
     * ID of the tag
     */
    tagId?: pulumi.Input<number | undefined>;
    /**
     * Name of the tag
     */
    tagName?: pulumi.Input<string | undefined>;
    /**
     * UUID of the tag
     */
    uuid?: pulumi.Input<string | undefined>;
}
/**
 * The set of arguments for constructing a Tag resource.
 */
export interface TagArgs {
    /**
     * Description of the feature
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * UUID of project the tag belongs to
     */
    projectUuid: pulumi.Input<string>;
    /**
     * Colour for this tag, as accepted by [color-string](https://github.com/Qix-/color-string).
     */
    tagColour?: pulumi.Input<string | undefined>;
    /**
     * Name of the tag
     */
    tagName: pulumi.Input<string>;
}
//# sourceMappingURL=tag.d.ts.map