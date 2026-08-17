<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\Relations\MorphToMany;

class Property extends Model
{
    protected $table = 'properties';

    protected $fillable = [
        'host_id',
        'city_id',
        'property_type',
        'booking_mode',
        'name',
        'building_name',
        'description',
        'address',
        'latitude',
        'longitude',
        'guest_capacity',
        'bedrooms',
        'bathrooms',
        'status',
        'cancellation_policy',
    ];

    protected $casts = [
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
    ];

    public function host(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function city(): BelongsTo
    {
        return $this->belongsTo(City::class);
    }

    public function media(): MorphMany
    {
        return $this->morphMany(Media::class, 'model')->orderBy('sort_order');
    }

    public function facilities(): MorphToMany
    {
        return $this->morphToMany(Facility::class, 'model', 'model_has_facilities')
            ->withPivot('is_available', 'badge', 'sort_order')
            ->orderBy('sort_order');
    }

    public function prices(): HasMany
    {
        return $this->hasMany(PropertyPrice::class);
    }

    public function pricingOptions(): HasMany
    {
        return $this->hasMany(PropertyPricingOption::class)->orderBy('sort_order');
    }

    public function specialPrices(): HasMany
    {
        return $this->hasMany(PropertySpecialPrice::class);
    }

    public function addOns(): HasMany
    {
        return $this->hasMany(PropertyAddOn::class)->orderBy('sort_order');
    }

    public function paymentPlans(): HasMany
    {
        return $this->hasMany(PropertyPaymentPlan::class);
    }

    public function promos(): HasMany
    {
        return $this->hasMany(PropertyPromo::class);
    }

    public function other(): HasOne
    {
        return $this->hasOne(PropertyOtherCore::class);
    }

    public function extraDescriptions(): HasMany
    {
        return $this->hasMany(PropertyExtraDescription::class)->orderBy('sort_order');
    }

    public function reviewSummary(): HasOne
    {
        return $this->hasOne(PropertyReviewSummary::class);
    }

    public function specs(): HasMany
    {
        return $this->hasMany(PropertySpec::class)->orderBy('sort_order');
    }

    public function bedFacilities(): HasMany
    {
        return $this->hasMany(PropertyBedFacility::class)->orderBy('sort_order');
    }

    public function buildingFacilities(): HasMany
    {
        return $this->hasMany(PropertyBuildingFacility::class)->orderBy('sort_order');
    }

    public function buildingFacilitiesAll(): HasMany
    {
        return $this->hasMany(PropertyBuildingFacilityAll::class)->orderBy('sort_order');
    }

    public function roomFurniture(): HasMany
    {
        return $this->hasMany(PropertyRoomFurniture::class)->orderBy('sort_order');
    }

    public function roomFurnitureGroups(): HasMany
    {
        return $this->hasMany(PropertyRoomFurnitureGroup::class)->orderBy('sort_order');
    }

    public function checkInNotes(): HasMany
    {
        return $this->hasMany(PropertyCheckInNote::class)->orderBy('sort_order');
    }

    public function depositNotes(): HasMany
    {
        return $this->hasMany(PropertyDepositNote::class)->orderBy('sort_order');
    }

    public function unitDetails(): HasMany
    {
        return $this->hasMany(PropertyUnitDetail::class)->orderBy('sort_order');
    }

    public function nearbyPlaces(): HasMany
    {
        return $this->hasMany(PropertyNearbyPlace::class)->orderBy('sort_order');
    }

    public function guestMedia(): MorphMany
    {
        return $this->morphMany(Media::class, 'model');
    }

    public function buildingUnits(): HasMany
    {
        return $this->hasMany(PropertyBuildingUnit::class)->orderBy('sort_order');
    }

    public function questions(): HasMany
    {
        return $this->hasMany(PropertyQuestion::class);
    }

    public function recommendations(): HasMany
    {
        return $this->hasMany(PropertyRecommendation::class);
    }

    public function searchLogs(): HasMany
    {
        return $this->hasMany(PropertySearchLog::class);
    }

    public function hotel(): HasOne
    {
        return $this->hasOne(Hotel::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function cover(): ?string
    {
        return $this->media->first()?->url;
    }

    public function gallery(): array
    {
        return $this->media->pluck('url')->toArray();
    }
}
